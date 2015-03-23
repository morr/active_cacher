# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_cacher/version'

Gem::Specification.new do |spec|
  spec.name          = 'active_cacher'
  spec.version       = ActiveCacher::VERSION
  spec.authors       = ['Andrey Sidorov', 'Alexey Terekhov']
  spec.email         = ['takandar@gmail.com', 'alexey.terekhov.ingate@gmail.com']

  spec.summary       = %q{Module for caching results of method invocations.}
  spec.homepage      = 'https://github.com/morr/active_cacher'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '> 3.0'
  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'pry-byebug'
end
