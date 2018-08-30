require 'minitest'
require 'minitest/spec'
require 'minitest/autorun'

require 'replr/process_runner'
require 'replr/stack/node/repl_maker'

describe Replr::Stack::Node::REPLMaker do
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
  def erwi(command, inputs, prompt_line, expected_output)
    Replr::ProcessRunner.new.execute_repl_with_input(command: "bin/replr #{command}",
                                                     inputs: inputs + ['.exit'],
                                                     prompt_line: prompt_line,
                                                     expected_output: expected_output)
  end

  it 'runs a simple node REPL' do
    erwi('node', ["console.log('1 + 2 =', 1 + 2)"],
         /^> $/, /1 \+ 2 = 3/m).must_equal true
  end
end
