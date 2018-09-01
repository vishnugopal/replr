require 'minitest'
require 'minitest/spec'
require 'minitest/autorun'

require 'replr/process_runner'
require 'replr/stack/python/repl_maker'

require_relative '../../../spec_helper'

describe Replr::Stack::Python::REPLMaker do
  include SpecHelper

  before do
    configure_erwi(command_prefix: 'bin/replr', exit_line: 'exit()',
                   prompt_line: /^>>> $/)
  end

  it 'runs a simple python REPL' do
    erwi('python', ['print("1 + 2 =", 1 + 2)'], /1 \+ 2 = 3/m).must_equal true
  end

  it 'runs a python REPL for a specific version' do
    erwi('python:3.6.6', ['import sys; print(sys.version)'], /3\.6\.6/m).must_equal true
  end

  it 'runs a python REPL with one library' do
    erwi('python requests', ["import requests; requests.get"],
         /function get at/m).must_equal true
  end

  it 'runs a python REPL with multiple libraries' do
    erwi('python requests flask', ["import flask; print(flask.__version__)"],
         /[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2}/m).must_equal true
  end

  it 'runs a ruby REPL with a specific version of a gem' do
    erwi('python flask:1.0.1', ["import flask; print(flask.__version__)"],
         /1\.0\.1/m).must_equal true
  end
end
