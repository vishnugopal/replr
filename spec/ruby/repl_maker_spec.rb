require 'minitest'
require 'minitest/spec'
require 'minitest/autorun'

require 'replr/process_runner'
require 'replr/stack/ruby/repl_maker'

require_relative '../spec_helper'

describe Replr::Stack::Ruby::REPLMaker do
  include SpecHelper

  before do
    configure_erwi(command_prefix: 'bin/replr', exit_line: 'exit',
                   prompt_line: /^(.*?)> $/)
  end

  it 'runs a simple ruby REPL' do
    erwi('ruby', ['puts("1 + 2 = #{1 + 2}")'], /1 \+ 2 = 3/m).must_equal true
  end

  it 'runs a ruby REPL for a specific version' do
    erwi('ruby:2.5.0', ['puts RUBY_VERSION'], /2\.5\.0/m).must_equal true
  end

  it 'runs a ruby REPL with one gem' do
    erwi('ruby chronic', ["puts Chronic.parse('March 14, 2018')"],
         /2018\-03\-14/m).must_equal true
  end

  it 'runs a ruby REPL with multiple gems' do
    erwi('ruby chronic activesupport', ["puts Gem.loaded_specs['activesupport'].version.to_s"],
         /[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2}/m).must_equal true
  end

  it 'runs a ruby REPL with a specific version of a gem' do
    erwi('ruby activesupport:5.2.0', ["puts Gem.loaded_specs['activesupport'].version.to_s"],
         /5\.2\.0/m).must_equal true
  end
end
