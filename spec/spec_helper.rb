require "active_record"
require "erb"
require "yaml"

require "validates_lengths_from_database"

# Establish DB Connection
database_configs = YAML.safe_load(ERB.new(File.read(File.join(__dir__, "db", "database.yml"))).result)
ActiveRecord::Base.establish_connection(database_configs.fetch(ENV.fetch("DB", "sqlite3")))

def postgresql?
  ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
end

def mysql?
  ActiveRecord::Base.connection.adapter_name.start_with?("Mysql")
end

# Only SQLite records arbitrary limits on TEXT columns. PostgreSQL has no
# limit, and MySQL rounds up to the nearest TEXT type (TINYTEXT is 255 bytes).
def small_text_limits?
  !postgresql? && !mysql?
end

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.expect_with(:rspec) { |expectations| expectations.syntax = :expect }
  config.mock_with(:rspec) { |mocks| mocks.syntax = :expect }
end

# Load Test Schema into the Database
ActiveRecord::Migration.verbose = false
load(File.join(__dir__, "db", "schema.rb"))
