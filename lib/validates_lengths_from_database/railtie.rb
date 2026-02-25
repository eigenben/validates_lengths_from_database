module ValidatesLengthsFromDatabase
  if defined?(Rails::Railtie)
    require "rails"

    class Railtie < Rails::Railtie
      initializer "validates_lengths_from_database.i18n" do
        locale_path = File.expand_path("../../../config/locales/en.yml", __FILE__)
        I18n.load_path << locale_path if File.exist?(locale_path)
      end

      initializer "validates_lengths_from_database.extend_active_record" do
        ActiveSupport.on_load(:active_record) do
          ValidatesLengthsFromDatabase::Railtie.insert
        end
      end
    end
  end

  class Railtie
    def self.insert
      ActiveRecord::Base.send(:include, ValidatesLengthsFromDatabase)
    end
  end
end

