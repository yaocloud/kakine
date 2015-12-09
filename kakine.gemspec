# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kakine/version'

Gem::Specification.new do |spec|
  spec.name          = "kakine"
  spec.version       = Kakine::VERSION
  spec.authors       = ["SHIBATA Hiroshi"]
  spec.email         = ["hsbt@ruby-lang.org"]

  spec.summary       = %q{Security Group configuration tool for OpenStack.}
  spec.description   = %q{Security Group configuration tool for OpenStack. You can apply simple YAML definition into Security Group on OpenStack.}
  spec.homepage      = "https://github.com/hsbt/kakine"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'fog'
  spec.add_dependency "yao", "~> 0.1.0"
  spec.add_dependency 'thor'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "mocha"
end
