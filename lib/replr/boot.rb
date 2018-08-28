require_relative '../replr'
require_relative 'argument_processor'
require_relative 'process_runner'

require 'tmpdir'
require 'open3'

# :nodoc:
module Replr
  # Starts up REPL creation & wires up rest of the pieces
  class Boot
    attr_reader :argument_processor, :process_runner

    def start
      @argument_processor = Replr::ArgumentProcessor.new
      @process_runner = Replr::ProcessRunner.new

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
      elsif argument_processor.stack == 'ruby'
        require_relative 'stack/ruby/repl_maker'
        ruby_repl_maker = Replr::Stack::Ruby::REPLMaker.new(
          stack: argument_processor.stack,
          libraries: argument_processor.libraries
        )
        ruby_repl_maker.create
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
