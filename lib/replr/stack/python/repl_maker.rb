require_relative '../../../replr'
require_relative '../../process_runner'

# :nodoc:
module Replr
  module Stack
    module Python
      # Creates a Python REPL using docker for a stack and libraries combo
      class REPLMaker
        attr_reader :process_runner
        attr_reader :stack, :libraries, :workdir

        def initialize(stack:, libraries:)
          @process_runner = Replr::ProcessRunner.new

          @stack = stack
          @libraries = libraries
          @workdir = Dir.mktmpdir
        end

        def create
          copy_library_file
          copy_initialization_files
          initialize_docker_repl
        end

        private

        def copy_library_file
          Dir.chdir(workdir) do
            File.open('requirements.txt', 'w') do |f|
              f.write(library_file_with(libraries))
            end
          end
        end

        def copy_initialization_files
          create_docker_file
        end

        def create_docker_file
          _stack, version = stack.split(':')
          docker_file_template = "#{__dir__}/Dockerfile.template"
          docker_file_contents = File.read(docker_file_template)
          docker_file_contents.gsub!('%%VERSION%%', version ? "#{version}-" : '')
          File.open(File.join(workdir, 'Dockerfile'), 'w') do |file|
            file.puts docker_file_contents
          end
        end

        def library_file_with(libraries)
          requirements = ''
          libraries.each do |library|
            if library.include?(':')
              library, version = library.split(':')
              requirements << "#{library}==#{version}\n"
            else
              requirements << "#{library}\n"
            end
          end
          requirements
        end

        def initialize_docker_repl
          Dir.chdir(workdir) do
            build_command = "docker build -t #{docker_image_tag} ."
            run_command = "docker run --rm -it #{docker_image_tag}"
            matching = Regexp.union([/upgrading/i, /installing/i, /pip/i])
            not_matching = Regexp.union([/step/i])
            process_runner.execute_filtered_process(build_command, matching,
                                                    not_matching) do |stderr, process_thread|
              process_runner.execute_command_if_not_stderr(run_command, stderr, process_thread)
            end
          end
        end

        def docker_image_tag
          normalized_library_string = libraries.map do |library|
            library.gsub(':', '-v')
          end.join('-')
          normalized_stack_string = stack.gsub(':', '-v')

          if normalized_library_string.empty?
            "replr/#{normalized_stack_string}"
          else
            "replr/#{normalized_stack_string}-#{normalized_library_string}"
          end
        end
      end
    end
  end
end
