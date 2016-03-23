Gem::Specification.new do |s|
  s.name        = 'rs-selfservice-tools'
  s.version     = '0.0.1'
  s.date        = '2016-02-12'
  s.summary     = "rs-selfservice-tools"
  s.description = "RightScal Self Service Tools."
  s.authors     = ["Ryan O'Leary"]
  s.email       = 'support@rightscale.com'
  s.licenses    = ['None']
  s.files       = Dir['lib/*.rb'] + Dir['bin/*.rb']
  s.bindir      = 'bin'
  s.executables = Dir.entries(s.bindir) - ['.', '..', '.gitignore', '.rubocop.yml']
  s.homepage    = 'https://github.com/ryanoleary/rs-selfservice-tools'
  s.add_runtime_dependency 'right_api_client', '~> 1.6'
end
