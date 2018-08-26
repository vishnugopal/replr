require_relative '../replr'

module Replr
  # Executes and manages processes
  class ProcessRunner
    # Executes command using system. Use this when you have no
    # need for a return value
    def execute_command(command)
      system(command)
    end

    # Checks whether process exists using `which`
    def process_exists?(process)
      system("which #{process} >/dev/null")
    end

    # Runs *command* and only prints those lines that match
    # *matching_regex* and doesn't match *not_matching_regex*. After
    # execution, it passes *stderr* and the waiting *process_thread*
    # to a block.
    def execute_filtered_process(command, matching_regex,
                                 not_matching_regex, &_block)
      Open3.popen3(command) do |_stdin, stdout, stderr, process_thread|
        stdout.each_line do |outline|
          if outline.match(matching_regex) &&
             !outline.match(not_matching_regex)
            puts outline
          end
        end

        # Yield to block to process next set of commands or handle stderr
        yield(stderr, process_thread)
      end
    end

    # Executes *new_command* if the previous *process_thread* had a
    # non-zero return. Otherwise prints out *stderr* of the previous
    # process to *STDERR*
    def execute_command_if_not_stderr(new_command, stderr, process_thread)
      outerror = stderr.read.chomp
      if process_thread.value.to_i.zero?
        system(new_command)
      else
        STDERR.puts outerror
      end
    end
  end
end
