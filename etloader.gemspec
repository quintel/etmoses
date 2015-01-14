# encoding: utf-8
$:.push File.expand_path('../lib', __FILE__)
require 'etloader/version'

Gem::Specification.new do |gem|
  gem.name        = 'etloader'
  gem.version     = ETLoader::VERSION.dup
  gem.platform    = Gem::Platform::RUBY
  gem.summary     = 'Load calculation in testing grounds'
  gem.description = 'Load calculation in testing grounds'
  gem.email       = 'dev@quintel.com'
  gem.homepage    = 'https://github.com/quintel/etloader'
  gem.authors     = ['Dennis Schoenmakers', 'Anthony Williams']

  gem.files       = `git ls-files`.split($/)
  gem.executables = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files  = gem.files.grep(%r{^(test|spec|features)/})

  gem.require_paths = ['lib']

  gem.required_ruby_version = '>= 2.2.0'

  gem.add_dependency 'turbine-graph', '>= 0.1'

  gem.add_development_dependency 'rake',  '>= 10.3.0'
  gem.add_development_dependency 'rspec', '>= 3.1.0'
end
