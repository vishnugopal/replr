require_relative '../../replr'
require_relative '../process_runner'

# :nodoc:
module Replr
  module Stack
    # Abstract class to do many things common when creating a REPL
    # across stacks
    class REPLMaker
      attr_reader :process_runner
      attr_reader :stack, :libraries, :work_dir
      attr_reader :library_file_name, :bootstrap_file_name, :template_dir,
                  :filter_matching_lines_for_install,
                  :filter_not_matching_lines_for_install

      def self.load(stack:, libraries:)
        stack_name, _stack_ersion = stack.split(':')
        require_relative "#{stack}/repl_maker"

        repl_maker_class_name = "Replr::Stack::#{stack_name.capitalize}::REPLMaker"
        repl_maker = Object.const_get(repl_maker_class_name).new(
          stack: stack,
          libraries: libraries
        )
        repl_maker.create
      end

      def initialize(stack:, libraries:)
        @process_runner = Replr::ProcessRunner.new

        @stack = stack
        @libraries = libraries
        @work_dir = Dir.mktmpdir
      end

      def create
        set_template_dir
        set_library_file_name
        set_bootstrap_file_name
        set_filter_lines_for_install

        copy_library_file
        copy_initialization_files
        initialize_docker_repl
      end

      private

      def set_template_dir
        raise NotImplementedError, 'This needs to be implemented by a subclass'
      end

      def set_library_file_name
        raise NotImplementedError, 'This needs to be implemented by a subclass'
      end

      # It's optional to set a bootstrap file
      def set_bootstrap_file_name; end

      def set_filter_lines_for_install
        raise NotImplementedError, 'This needs to be implemented by a subclass'
      end

      def library_file_with(libraries)
        raise NotImplementedError, 'This needs to be implemented by a subclass'
      end

      def copy_library_file
        Dir.chdir(work_dir) do
          File.open(library_file_name, 'w') do |f|
            f.write(library_file_with(libraries))
          end
        end
      end

      def copy_initialization_files
        create_docker_file
        if bootstrap_file_name
          bootstrap_file = File.join(template_dir, bootstrap_file_name)
          FileUtils.cp(bootstrap_file, work_dir)
        end
      end

      def create_docker_file
        _stack, version = stack.split(':')
        docker_file_template = File.join(template_dir, "Dockerfile.template")
        docker_file_contents = File.read(docker_file_template)
        docker_file_contents.gsub!('%%VERSION%%', version ? "#{version}-" : '')
        File.open(File.join(work_dir, 'Dockerfile'), 'w') do |file|
          file.puts docker_file_contents
        end
      end

      def initialize_docker_repl
        Dir.chdir(work_dir) do
          build_command = "docker build -t #{docker_image_tag} ."
          run_command = "docker run --rm -it #{docker_image_tag}"
          matching = Regexp.union([/upgrading/i, /installing/i] +
                                   filter_matching_lines_for_install)
          not_matching = Regexp.union([/step/i] + filter_not_matching_lines_for_install)
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
