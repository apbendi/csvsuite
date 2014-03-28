# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'csvsuite/version'

Gem::Specification.new do |gem|
  gem.name          = "csvsuite"
  gem.version       = CSVSuite::VERSION
  gem.authors       = ["Ben Di"]
  gem.email         = ["bdifrancesco@ascensionpress.com"]
  gem.description   = %q{Classes for doing things with CSVs easier}
  gem.summary       = %q{Wrapper around csv class for easier merging, etc...}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = ["mergify", "excelify", "addressify"]
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
