# frozen_string_literal: true

require_relative "lib/pebble/version"

Gem::Specification.new do |spec|
  spec.name = "pebble"
  spec.version = Pebble::VERSION
  spec.authors = ["Opus1no2"]
  spec.email = ["tillotson.travis@gmail.com"]

  spec.summary = "Micro framework."
  spec.description = "Micro framework for learning purposes only."
  spec.homepage = "N/A"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["allowed_push_host"] = "N/A"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "N/A"
  spec.metadata["changelog_uri"] = "N/A"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rack", "> 3.0.0", "< 4"
end
