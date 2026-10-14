require_relative "lib/validates_lengths_from_database/version"

Gem::Specification.new do |s|
  s.name        = "validates_lengths_from_database"
  s.version     = ValidatesLengthsFromDatabase::VERSION
  s.author      = "Ben Hughes"
  s.email       = "me@benhughes.name"
  s.homepage    = "https://github.com/eigenben/validates_lengths_from_database"
  s.summary     = "Automatic maximum-length validations."
  s.description = "Introspects your database string field maximum lengths and automatically defines length validations."
  s.license     = "MIT"

  s.metadata = {
    "source_code_uri"       => s.homepage,
    "changelog_uri"         => "#{s.homepage}/blob/main/CHANGELOG.md",
    "bug_tracker_uri"       => "#{s.homepage}/issues",
    "rubygems_mfa_required" => "true"
  }

  s.files        = Dir["{lib,config}/**/*", "LICENSE", "README*", "CHANGELOG*"]
  s.require_path = "lib"

  s.required_ruby_version = ">= 2.7"

  s.add_dependency("activerecord", ">= 6.1")
end
