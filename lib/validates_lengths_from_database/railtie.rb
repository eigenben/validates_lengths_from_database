module ValidatesLengthsFromDatabase
  # Kept for apps that call Railtie.insert themselves. Requiring the gem now
  # adds it to ActiveRecord::Base, so this is no longer needed.
  class Railtie
    def self.insert
      ActiveRecord::Base.include(ValidatesLengthsFromDatabase)
    end
  end
end
