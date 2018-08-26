require_relative '../replr'

# :nodoc:
module Replr
  # Processes command-line arguments
  class ArgumentProcessor
    attr_reader :arguments

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
      unless ['ruby', 'prune'].include? arguments[0]
        puts_error 'Only supports ruby as a stack right now'
        puts_usage
        exit
      end
    end

    def puts_usage
      puts_error "\nUsage: replr <stack> <libraries...>\n\n"
      puts_error "A single line REPL for your favorite languages & libraries\n\n"
      puts_error "\t<stack> is now only 'ruby'"
      puts_error "\t<libraries...> is a space separated list of libraries for the stack\n\n"
      puts_error "More commands:\n\n\treplr prune to delete all replr docker images (this saves space)"
    end
  end
end
