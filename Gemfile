source "https://rubygems.org"

gemspec

gem "rake"
gem "rspec", "~> 3.13"

# Set DB=postgresql or DB=mysql to run the specs against those databases.
# The gemfiles/ for older Rails versions pin a compatible sqlite3 first.
case ENV.fetch("DB", "sqlite3")
when "postgresql" then gem "pg", "~> 1.1"
when "mysql"      then gem "mysql2", "~> 0.5"
else
  gem "sqlite3", ">= 2.1" unless dependencies.any? { |dep| dep.name == "sqlite3" }
end
