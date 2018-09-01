# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = 'replr'
  s.version = '0.9.5'
  s.executables << 'replr'
  s.date = '2018-08-30'
  s.summary = 'A single line REPL for your favorite languages & libraries.'
  s.authors     = ['Vishnu Gopal']
  s.email       = 'vg@vishnugopal.com'
  s.files = ['Gemfile'] + Dir['lib/**/*.*']
  s.require_paths = ['lib']

  s.add_development_dependency 'minitest', '~> 0'
  s.add_development_dependency 'rake', '~> 0'

  s.homepage = 'https://github.com/vishnugopal/replr'
  s.license = 'MIT'
end
