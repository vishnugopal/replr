require 'minitest'
require 'minitest/spec'
require 'minitest/autorun'

require 'replr/process_runner'
require 'replr/stack/node/repl_maker'

require_relative '../spec_helper'

describe Replr::Stack::Node::REPLMaker do
  include SpecHelper

  before { configure_erwi(command_prefix: 'bin/replr', exit_line: '.exit') }

  it 'runs a simple node REPL' do
    erwi('node', ["console.log('1 + 2 =', 1 + 2)"],
         /^> $/, /1 \+ 2 = 3/m).must_equal true
  end

  it 'runs a node REPL for a specific version' do
    erwi('node:10.8.0', ['process.versions'],
         /^> $/, /node:(.*?)'10.8.0'/m).must_equal true
  end

  it 'runs a node REPL with one module' do
    erwi('node request', ["var request = require('request'); request.get"],
         /^> $/, /Function/m).must_equal true
  end

  it 'runs a node REPL with multiple modules' do
    erwi('node request express', ["require('/app/node_modules/express/package.json').version"],
         /^> $/, /[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2}/m).must_equal true
  end

  it 'runs a node REPL with a specific version of a module' do
    erwi('node express:4.16.0', ["require('/app/node_modules/express/package.json').version"],
         /^> $/, /4\.16\.0/m).must_equal true
  end
end
