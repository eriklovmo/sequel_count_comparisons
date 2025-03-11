# Sequel::CountComparisons

This gem adds three methods to `Sequel::Dataset`:

* `#count_equals?`
* `#count_less_than?`
* `#count_greater_than?`

These methods allow you to efficiently compare a dataset's row count to a given number.

Why use this gem?

* It generates efficient SQL queries to minimize database overhead, using
`LIMIT`
and `OFFSET` clauses to count only the rows needed. This is especially useful
for large datasets.
* It provides a readable API for expressing dataset count comparisons, which
makes code easier to understand and less error-prone.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add sequel_count_comparisons

If Bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install sequel_count_comparisons

## Usage

You can load this extension into specific datasets:

```ruby
ds = DB[:table].extension(:count_comparisons)
``````

Or you can load it into all of a database’s datasets:

```ruby
DB.extension(:count_comparisons)

DB[:table].count_equals?(1)
# SELECT EXISTS (SELECT 1 FROM table OFFSET 0) AND NOT EXISTS (SELECT 1 FROM table OFFSET 1)

DB[:table].count_equals?(0)
# SELECT 1 FROM table LIMIT 1

DB[:table].count_greater_than?(0)
# SELECT 1 FROM table LIMIT 1

DB[:table].count_greater_than?(1)
# SELECT 1 FROM table LIMIT 1 OFFSET 1

DB[:table].count_less_than?(1)
# SELECT 1 FROM table LIMIT 1

DB[:table].count_less_than?(5)
# SELECT 1 FROM table LIMIT 1 OFFSET 4

```

## Caveats

The gem is tested on PostgreSQL. It may or may not work for other databases.

## License

This library is released under the MIT License.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/eriklovmo/sequel_count_comparisons.
