Gem::Specification.new do |s|
  s.name = 'replr'
  s.version = '0.2.0'
  s.executables << 'replr'
  s.date = '2018-08-24'
  s.summary = 'A single line REPL for your favorite languages & libraries.'
  s.authors     = ['Vishnu Gopal']
  s.email       = 'vg@vishnugopal.com'
  s.files = [
    'Gemfile',
    'lib/replr.rb',
    'lib/Dockerfile',
    'lib/replr-bootstrap.rb'
  ]
  s.require_paths = ['lib']

  s.homepage = 'https://github.com/vishnugopal/replr'
  s.license = 'MIT'
end
