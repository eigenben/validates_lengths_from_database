# Changelog

## v1.1.0 (2026-10-14)

- Validate that integer columns can hold the value, including MySQL `TINYINT` and `UNSIGNED` columns. Values Rails would refuse to save with an `ActiveModel::RangeError` now fail validation with "is out of range" (the `out_of_range` key) instead (#33)

## v1.0.1 (2026-10-14)

- Add `validates_lengths_from_database` to ActiveRecord::Base whenever the gem is required, so it works without Rails and no longer depends on Rails being loaded first (#23)

## v1.0.0 (2026-10-14)

- Require Rails (ActiveRecord) 6.1+ and Ruby 2.7+. Apps on older versions can stay on 0.8.x.
- Tested against Rails 6.1 through 8.1 on SQLite, PostgreSQL and MySQL.
- The "too long (bytes)" error for TEXT columns can now be translated with the `too_long_bytes` key (#42) - thanks @Bhalani
- Validate the lower bound of DECIMAL columns, so -1000 is rejected for DECIMAL(5,2)
- No longer modify the options hash passed to `validates_lengths_from_database`
- Accept string keys in the `:limit` hash

## v0.8.0 (2019-10-30)

- Enforce validation length on TEXT columns via bytes instead of characters (#25)
- Drop support for ruby 1.9 (#26)

## v0.7.0 (2017-10-09)

- Drop hard reliance on rails (can use with just activerecord) - thanks @grosser
- Drop requiring of rubygems (unnecessary) - thanks @grosser
- Update dependencies to modern, build-able versions

## v0.6.0 (2017-05-02)

- Drop support for integer length validations (too many issues)

## v0.5.2 (2017-04-28)

- Fix handling with STI models - thanks @iNecas

## v0.5.1 (2017-04-27)

- Fix sharing options between models - thanks @iNecas

## v0.5.0 (2016-01-28)

- Drop support for rails 2
- Implement lazy-evaluation of column information for better compatibility with early load orders - thanks @domcleal.

## v0.4.0 (2015-01-03)

- Drop support for ruby 1.8.7 and 1.9.2 - too many issues with backwards-compatibility

## v0.3.0 (2015-01-03)

- Explicit support for Rails 4.1 and 4.2
- Up-to-date Appraisals and dependencies
- Better support for postgres text columns via conditional length validation
- Bug fix for postgres array column types

