# frozen_string_literal: true

require 'sequel'
require_relative '../count_comparisons/version'

# The count_comparisons extension adds the #count_greater_than?, #count_less_than?
# and #count_equals? methods to Dataset. These methods can be used to efficiently
# compare a dataset's row count to a given number.

# You can load this extension into specific datasets:
#
#   ds = DB[:table].extension(:count_comparisons)
#
# Or load it into all of a database's datasets:
#
#   DB.extension(:count_comparisons)

module Sequel
  module Extensions
    module CountComparisons
      LITERAL_1 = Sequel::SQL::AliasedExpression.new(1, :one)
      private_constant :LITERAL_1

      # Returns true if more than *number_of_rows* records exist in the dataset, false otherwise
      #
      # Equivalent to a "greater than" (>) comparison
      #
      # @param number_of_rows [Integer] The number to compare against
      # @return [Boolean] Whether the dataset contains more rows than *number_of_rows*
      # @raise [ArgumentError] If `number_of_rows` is not an integer
      def count_greater_than?(number_of_rows)
        unless number_of_rows.is_a?(Integer)
          raise ArgumentError,
                "`number_of_rows` must be an Integer, got #{number_of_rows.inspect}"
        end

        if number_of_rows.negative?
          true
        elsif number_of_rows.zero?
          !empty?
        else
          ds = @opts[:sql] ? from_self : self
          !ds.offset(number_of_rows).empty?
        end
      end

      # Returns true if fewer than *number_of_rows* records exist in the dataset, false otherwise
      #
      # Equivalent to a "less than" (<) comparison
      #
      # @param number_of_rows [Integer] The number to compare against
      # @return [Boolean] Whether the dataset contains fewer rows than *number_of_rows*
      # @raise [ArgumentError] If `number_of_rows` is not an integer
      def count_less_than?(number_of_rows)
        unless number_of_rows.is_a?(Integer)
          raise ArgumentError,
                "`number_of_rows` must be an Integer, got #{number_of_rows.inspect}"
        end

        !count_greater_than?(number_of_rows - 1)
      end

      # Returns true if exactly *number_of_rows* records exist in the dataset, false otherwise
      #
      # Equivalent to an "equal to" (==) comparison
      #
      # @param number_of_rows [Integer] The number to compare against
      # @return [Boolean] Whether the dataset contains exactly *number_of_rows*
      # @raise [ArgumentError] If `number_of_rows` is not an integer
      def count_equals?(number_of_rows)
        unless number_of_rows.is_a?(Integer)
          raise ArgumentError,
                "`number_of_rows` must be an Integer, got #{number_of_rows.inspect}"
        end

        if number_of_rows.negative?
          false
        elsif number_of_rows.zero?
          empty?
        else
          ds = @opts[:sql] ? from_self : self
          ds = ds.unordered.select(LITERAL_1)
          @db.get(
            ds.offset(number_of_rows - 1).exists &
            ~ds.offset(number_of_rows).exists
          )
        end
      end
    end
  end

  Sequel::Dataset.register_extension(:count_comparisons, Sequel::Extensions::CountComparisons)
end
