require_relative '../replr'
require_relative 'process_runner'

# :nodoc:
module Replr
  # Creates a REPL using docker for a stack and libraries combo
  class REPLMaker
    attr_reader :process_runner
    attr_reader :stack, :libraries, :workdir

    def initialize(stack:, libraries:)
      @process_runner = Replr::ProcessRunner.new

      @stack = stack
      @libraries = libraries
      @workdir = Dir.mktmpdir
    end

    def copy_library_file
      Dir.chdir(workdir) do
        File.open('Gemfile', 'w') do |f|
          f.write(library_file_with(libraries))
        end
      end
    end

    def copy_initialization_files
      create_docker_file
      bootstrap_file = "#{__dir__}/replr-bootstrap.rb"
      FileUtils.cp(bootstrap_file, workdir)
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
      gemfile = "source 'https://rubygems.org/'\n"
      libraries.each do |library|
        if library.include?(':')
          library, version = library.split(':')
          gemfile << "gem '#{library}', '#{version}'\n"
        else
          gemfile << "gem '#{library}'\n"
        end
      end
      gemfile
    end

    def initialize_docker_repl
      Dir.chdir(workdir) do
        build_command = "docker build -t #{docker_image_tag} ."
        run_command = "docker run --rm -it #{docker_image_tag}"
        matching = Regexp.union([/upgrading/i, /installing/i, /gem/i])
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

      "replr/#{normalized_stack_string}-#{normalized_library_string}"
    end
  end
end
