module ValidatesLengthsFromDatabase
  extend ActiveSupport::Concern

  class BytesizeValidator < ActiveModel::Validations::LengthValidator
    def validate_each(record, attribute, value)
      value_for_validation = value.is_a?(String) ? value.bytes : value

      super(record, attribute, value_for_validation)
    end
  end

  module ClassMethods
    def validates_lengths_from_database(options = {})
      # Copy everything we keep so later changes to the stored options
      # (see README) never leak back into the caller's hash or arrays.
      options = options.symbolize_keys

      options[:only]   = Array(options[:only]).dup   if options[:only]
      options[:except] = Array(options[:except]).dup if options[:except]

      limit = options[:limit] || {}
      options[:limit] = limit.is_a?(Hash) ? limit.symbolize_keys : {:string => limit, :text => limit}

      @validate_lengths_from_database_options = options

      validate :validate_lengths_from_database

      nil
    end

    def validate_lengths_from_database_options
      if defined? @validate_lengths_from_database_options
        @validate_lengths_from_database_options
      else
        # in case we inherited the validations, copy the options so that we can update it in child
        # without affecting the parent
        @validate_lengths_from_database_options = superclass.validate_lengths_from_database_options.inject({}) do |hash, (key, value)|
          value = value.dup if value.respond_to?(:dup)
          hash.update(key => value)
        end
      end
    end
  end

  def validate_lengths_from_database
    options = self.class.validate_lengths_from_database_options

    if options[:only]
      columns_to_validate = options[:only].map(&:to_s)
    else
      columns_to_validate = self.class.column_names.map(&:to_s)
      columns_to_validate -= options[:except].map(&:to_s) if options[:except]
    end

    columns_to_validate.each do |column|
      column_schema = self.class.columns_hash[column]

      next if column_schema.nil?
      next if column_schema.respond_to?(:array) && column_schema.array
      next unless [:string, :text, :decimal].include?(column_schema.type)

      case column_schema.type
      when :string
        if column_limit = options[:limit][column_schema.type] || column_schema.limit
          validate_length_by_characters(column, column_limit)
        end
      when :text
        if column_limit = options[:limit][column_schema.type] || column_schema.limit
          validate_length_by_bytesize(column, column_limit)
        end
      when :decimal
        if column_schema.precision && column_schema.scale
          validate_numericality_with_precision(column, column_schema)
        end
      end
    end
  end

  private

  def validate_length_by_characters(column, column_limit)
    ActiveModel::Validations::LengthValidator.new(
      :allow_blank => true,
      :attributes => [column],
      :maximum => column_limit
    ).validate(self)
  end

  def validate_length_by_bytesize(column, column_limit)
    BytesizeValidator.new(
      :allow_blank => true,
      :attributes => [column],
      :maximum => column_limit,
      :too_long => :too_long_bytes
    ).validate(self)
  end

  def validate_numericality_with_precision(column, column_schema)
    max_val = (10 ** column_schema.precision)/(10 ** column_schema.scale)

    ActiveModel::Validations::NumericalityValidator.new(
      :allow_blank => true,
      :attributes => [column],
      :less_than => max_val,
      :greater_than => -max_val
    ).validate(self)
  end
end
