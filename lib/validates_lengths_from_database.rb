require "active_support"
require "active_support/i18n"

I18n.load_path << File.expand_path("../config/locales/en.yml", __dir__)

require "validates_lengths_from_database/core"
require "validates_lengths_from_database/railtie"
