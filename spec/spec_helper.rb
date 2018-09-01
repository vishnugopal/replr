module SpecHelper
  def configure_erwi(command_prefix:, exit_line:, prompt_line:)
    @command_prefix = command_prefix
    @exit_line = exit_line
    @prompt_line = prompt_line
  end

  #
  # This is a shortcut to `Replr::ProcessRunner#execute_repl_with_input`
  # to make life easier.
  #
  # Note: we prefer integration tests to make sure all expected output is
  # working correctly. This way, we can also make sure the REPL inside the
  # docker container works well.
  # Note how the inputs have the 'exit' command appended to the end to
  # make sure we close the REPL stream correctly. Otherwise, we leave orphan
  # docker processes lying around.
  #
  def erwi(command, inputs, expected_output, debug: false)
    Replr::ProcessRunner.new.execute_repl_with_input(command: "#{@command_prefix} #{command}",
                                                     inputs: inputs + [@exit_line],
                                                     prompt_line: @prompt_line,
                                                     expected_output: expected_output,
                                                     debug: debug)
  end
end