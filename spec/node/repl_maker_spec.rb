require 'minitest'
require 'minitest/spec'
require 'minitest/autorun'

require 'replr/process_runner'

describe Array do
  # Just a shortcut to make life simpler
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
