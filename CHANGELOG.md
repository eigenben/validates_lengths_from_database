# Changelog

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

