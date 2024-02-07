# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'imazen_licensing/version'

Gem::Specification.new do |spec|
  spec.name          = "imazen_licensing"
  spec.version       = ImazenLicensing::VERSION
  spec.authors       = ["Lilith River"]
  spec.email         = ["nathanael.jones@gmail.com"]
  spec.summary       = %q{Licensing module for Imazen products}
  spec.description   = %q{Licensing module for Imazen products}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "fog-aws", "~> 3"
  spec.add_dependency "mime-types", "~> 3.1"
  spec.add_dependency "public_suffix", "~> 5"
  spec.add_dependency "chargebee", "~> 2"

  spec.add_development_dependency "bundler", "~> 2"
  spec.add_development_dependency "rake", "> 10.4.0"
  spec.add_development_dependency "minitest", "~> 5.22.1"
  spec.add_development_dependency "dotenv", "~> 2"
end
