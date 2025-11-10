# frozen_string_literal: true

require_relative "lib/haveibeenpwned/version"

Gem::Specification.new do |spec|
  spec.name = "sorbet-hibp"
  spec.version = HaveIBeenPwned::VERSION
  spec.authors = ["Angelos Kapsimanis"]
  spec.email = ["angelos@sorbet.ee"]

  spec.summary = "Ruby wrapper for the Have I Been Pwned API"
  spec.description = "A simple, clean Ruby client for the Have I Been Pwned API v3, supporting breach lookups, pastes, stealer logs, and pwned passwords"
  spec.homepage = "https://github.com/sorbet-ee/haveibeenpwned."
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  spec.files = Dir.glob("lib/**/*") + %w[LICENSE README.md]
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 2.0"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "webmock", "~> 3.0"
end
