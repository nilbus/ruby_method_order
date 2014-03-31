# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruby_method_order/version'

Gem::Specification.new do |spec|
  spec.name          = "ruby_method_order"
  spec.version       = RubyMethodOrder::VERSION
  spec.authors       = ["Edward Anderson"]
  spec.email         = ["nilbus@nilbus.com"]
  spec.description   = %q{Determine method order (instance, class, constructor) for files in a ruby project}
  spec.summary       = %q{Synopsis: Run bin/ruby_method_order <project_path>}
  spec.homepage      = "https://github.com/bbatsov/ruby-style-guide/pull/272"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
