# Validates Lengths from Database

[![CI](https://github.com/eigenben/validates_lengths_from_database/actions/workflows/ci.yml/badge.svg)](https://github.com/eigenben/validates_lengths_from_database/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/validates_lengths_from_database.svg)](https://rubygems.org/gems/validates_lengths_from_database)

Few people add length validations to fields in their database, and when saving such fields that have exhausted their length, an SQL error occurs.
This gem introspects your table schema for maximum lengths on string and text fields and automatically adds length validations to the model.

## Requirements

* Ruby 2.7 or newer
* ActiveRecord 6.1 or newer

For older versions of Rails or Ruby, use the 0.8.x releases.

## Installation

Include the gem using bundler in your Gemfile:

```ruby
gem "validates_lengths_from_database"
```

## Usage

In your model you can activate validations:

```ruby
class Post < ActiveRecord::Base
  validates_lengths_from_database
end
```

It also supports filter-style `:only` and `:except` options:

```ruby
class Post < ActiveRecord::Base
  validates_lengths_from_database only: [:title, :contents]
end

class Post < ActiveRecord::Base
  validates_lengths_from_database except: [:other_field]
end
```

If you'd rather specify the limits explicitly instead of pulling them from the database, you can set it:

```ruby
class Post < ActiveRecord::Base
  validates_lengths_from_database limit: 255
end
```

Or to set the limit differently for string (`VARCHAR`) and `TEXT` columns:

```ruby
class Post < ActiveRecord::Base
  validates_lengths_from_database limit: { string: 255, text: 4092 }
end
```

You can use `validates_lengths_from_database` on an abstract parent (without a table), such as `ApplicationRecord` or `ActiveRecord::Base`:

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  validates_lengths_from_database limit: 255
end

# This will use the validations with default options (from parent)
class Post < ApplicationRecord
end

# This will use the validations, with overriding the default options (the limit will not be applied)
class User < ApplicationRecord
  validates_lengths_from_database only: [:name]
end

# This will use the validations, using the default options + adding some class specific customizations
class Comment < ApplicationRecord
  validate_lengths_from_database_options[:only] << :name
end
```

## What gets validated

* **String (`VARCHAR`) columns** are limited to the column's length in characters.
* **`TEXT` columns** are limited to the column's length in bytes, since that is how MySQL measures them.
* **`DECIMAL` columns** with a precision and scale must fit within them. For example, `DECIMAL(5,2)` accepts -999.99 through 999.99.

Columns without a limit are skipped, so what this gem does depends on your database:

* **MySQL**: `t.string` columns are `VARCHAR(255)` and `t.text` columns are `TEXT` (65,535 bytes) unless you say otherwise. This is where the gem helps most, turning `ActiveRecord::ValueTooLong` exceptions into validation errors.
* **PostgreSQL**: Rails creates `t.string` columns with no length limit, and `TEXT` columns never have one, so only columns declared with an explicit `limit:` are validated.
* **SQLite**: limits declared in migrations are validated, even though SQLite itself does not enforce them.

## Translating the bytes error message

`TEXT` columns that are too long get the `too_long_bytes` error, which defaults to "is too long (maximum is %{count} bytes)".
Override it in your locale files like any other ActiveModel error message:

```yaml
en:
  errors:
    messages:
      too_long_bytes:
        one: "is too long (maximum is 1 byte)"
        other: "is too long (maximum is %{count} bytes)"
```

## Running Tests

The specs run against SQLite by default:

```
bundle install
bundle exec rspec
```

Set `DB=postgresql` or `DB=mysql` to test against those databases instead. Both expect a database named `validates_lengths_from_database_test`, and connection settings can be changed with environment variables (see `spec/db/database.yml`).

To test against a specific Rails version, use one of the gemfiles in `gemfiles/`:

```
BUNDLE_GEMFILE=gemfiles/rails_7.0.gemfile bundle install
BUNDLE_GEMFILE=gemfiles/rails_7.0.gemfile bundle exec rspec
```
