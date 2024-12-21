# frozen_string_literal: true

require_relative "lib/robodash/version"

Gem::Specification.new do |spec|
  spec.name = "robodash"
  spec.version = Robodash::VERSION
  spec.authors = ["Bram Jetten"]
  spec.email = ["mail@bramjetten.nl"]

  spec.summary = "A simple gem to send asynchronous POST requests to Robodash."
  spec.description = "Robodash is a lightweight Ruby gem for sending POST requests to Robodash's API. It is designed to be simple to use, with support for API tokens and background threading for non-blocking requests. Ideal for 'fire-and-forget' HTTP pings."
  spec.homepage = "https://beta.robodash.app"

  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Bramjetten/robodash-gem"

  spec.files = Dir["{lib}/**/*"] + ["README.md"]

  spec.require_paths = ["lib"]
end
