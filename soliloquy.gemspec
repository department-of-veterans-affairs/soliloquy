# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'soliloquy/version'

Gem::Specification.new do |spec|
  spec.name          = 'soliloquy'
  spec.version       = Soliloquy::VERSION
  spec.authors       = ['Alastair Dawson']
  spec.email         = ['alastair@adhocteam.us']

  spec.summary       = "A Ruby structured logger"
  spec.description   = 'A simple structured logger that can output in multiple formats with optional highlighting'
  spec.homepage      = 'https://github.com/department-of-veterans-affairs/soliloquay'
  spec.license       = 'CC0-1.0'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '~> 4.2.7'
  spec.add_dependency 'oj', '~> 2.17'

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.42'
  spec.add_development_dependency 'simplecov', '~> 0.12'
end
