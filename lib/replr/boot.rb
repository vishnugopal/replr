require_relative '../replr'
require_relative 'argument_processor'
require_relative 'process_runner'
require_relative 'repl_maker'

require 'tmpdir'
require 'open3'

# :nodoc:
module Replr
  # Starts up REPL creation & wires up rest of the pieces
  class Boot
    attr_reader :argument_processor, :process_runner, :repl_maker

    def start
      @argument_processor = Replr::ArgumentProcessor.new
      @process_runner = Replr::ProcessRunner.new
      @repl_maker = Replr::REPLMaker.new(stack: argument_processor.stack,
                                         libraries: argument_processor.libraries)

      check_docker!
      execute_processsed_arguments!
    end

    private

    def check_docker!
      unless process_runner.process_exists?('docker')
        puts_error 'Needs docker installed & in path to work.'
        exit
      end
    end

    def execute_processsed_arguments!
      if argument_processor.command == 'prune'
        execute_prune_command
      else
        repl_maker.copy_library_file
        repl_maker.copy_initialization_files
        repl_maker.initialize_docker_repl
      end
    end

    def execute_prune_command
      prune_command = %q(docker images -a |  grep "replr/" | awk '{print $3}' | xargs docker rmi)
      process_runner.execute_command(prune_command)
    end

    def puts_error(string)
      STDERR.puts(string)
    end
  end
end
