# :nodoc:
module Replr
  # Processes command-line arguments
  class ArgumentProcessor
    COMMANDS = ['prune'].freeze
    STACKS = ['ruby', 'python', 'node'].freeze

    attr_reader :arguments, :stack, :command, :libraries

    def initialize
      @arguments = ARGV.map { |argument| argument.downcase.strip }
      check_argument_length!
      check_arguments!
    end

    def check_argument_length!
      if arguments.empty?
        puts_usage
        exit
      end
    end

    def check_arguments!
      detect_stack
      detect_command
      detect_libraries

      unless stack || command
        puts_error "First argument must be either be a command:
\t#{COMMANDS.join(' ')}\nor one of a supported stack:
\t#{STACKS.join(' ')}"
        puts_usage
        exit
      end
    end

    def detect_stack
      detected_stack = STACKS.detect do |stack|
        arguments[0].match(/^#{stack}:?.*?/)
      end

      # return the full stack string (that includes version)
      # instead of just the stack name
      if detected_stack
        @stack = arguments[0]
      end
    end

    def detect_command
      @command = COMMANDS.detect do |command|
        arguments[0] == command
      end
    end

    def detect_libraries
      @libraries = arguments[1..-1].sort!
    end

    def puts_usage
      puts_error "\nUsage: replr <stack> <libraries...>\n\n"
      puts_error "A single line REPL for your favorite languages & libraries\n\n"
      puts_error "\t<stack> is now one of #{STACKS.join(', ')}"
      puts_error "\t<libraries...> is a space separated list of libraries for the stack\n\n"
      puts_error "More commands:\n\n\treplr prune to delete all replr docker images (this saves space)"
    end

    def puts_error(string)
      STDERR.puts(string)
    end
  end
end
