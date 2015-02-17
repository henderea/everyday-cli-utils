# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'everyday-cli-utils/version'

Gem::Specification.new do |spec|
  spec.name        = 'everyday-cli-utils'
  spec.version     = EverydayCliUtils::VERSION
  spec.authors     = ['Eric Henderson']
  spec.email       = ['henderea@gmail.com']
  spec.summary     = %q{A few CLI and general utils}
  spec.description = %q{A few CLI and general utilities.  Includes a numbered-menu select loop utility, a ANSI formatting escape code handler, a text-based histogram maker, k-means and n-means (k-means with minimum optimal k) calculators, various collection utility methods, and a utility for using OptionParser with less code.}
  spec.homepage    = 'https://github.com/henderea/everyday-cli-utils'
  spec.license     = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 1.9.3'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.4'
  spec.add_development_dependency 'rspec'
end
