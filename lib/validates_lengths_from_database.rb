require "active_support"
require "active_support/i18n"
require "active_model"

I18n.load_path << File.expand_path("../config/locales/en.yml", __dir__)

require "validates_lengths_from_database/core"
require "validates_lengths_from_database/railtie"

# Runs as soon as ActiveRecord::Base loads, or right away if it already has,
# so the gem works with or without Rails and regardless of require order.
ActiveSupport.on_load(:active_record) do
  include ValidatesLengthsFromDatabase
end
