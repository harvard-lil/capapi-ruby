# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))

require "capapi/version"

Gem::Specification.new do |s|
  s.name = "capapi"
  s.version = Capapi::VERSION
  s.required_ruby_version = ">= 2.0.0"
  s.summary = "Ruby bindings for Capapi"
  s.author = "Capapi"
  s.homepage = "https://capapi.org/"
  s.license = "MIT"

  s.add_dependency("faraday", "~> 0.10")

  s.files = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]
end
