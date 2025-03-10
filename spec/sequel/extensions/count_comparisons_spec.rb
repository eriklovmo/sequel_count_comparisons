# frozen_string_literal: true

require_relative '../../spec_helper'

RSpec.describe Sequel::CountComparisons do
  describe '#count_equals?' do
    context 'with `number_of_rows` below 0' do
      it 'returns false for an empty dataset' do
        expect(DB[:table].count_equals?(-1)).to be(false)
      end

      it 'returns false for a dataset with one row' do
        DB[:table].insert(column: 1)

        expect(DB[:table].count_equals?(-1)).to be(false)
      end

      it 'does not hit the database' do
        db = Sequel.mock.extension(:count_comparisons)

        db[:table].count_equals?(-1)

        expect(db.sqls).to be_empty
      end
    end

    context 'with `number_of_rows` = 0' do
      it 'returns true for an empty dataset' do
        expect(DB[:table].count_equals?(0)).to be(true)
      end

      it 'returns false for a dataset with one row' do
        DB[:table].insert(column: 1)

        expect(DB[:table].count_equals?(0)).to be(false)
      end

      it 'returns false for a dataset with multiple rows' do
        DB[:table].multi_insert([{ column: 1 }, { column: 2 }])

        expect(DB[:table].count_equals?(0)).to be(false)
      end

      it 'generates correct SQL' do
        db = Sequel.mock.extension(:count_comparisons)

        db[:table].count_equals?(0)

        expect(db.sqls).to contain_exactly('SELECT 1 AS one FROM table LIMIT 1')
      end
    end

    context 'with `number_of_rows` = 1' do
      it 'returns false for an empty dataset' do
        expect(DB[:table].count_equals?(1)).to be(false)
      end

      it 'returns true for a dataset with one row' do
        DB[:table].insert(column: 1)

        expect(DB[:table].count_equals?(1)).to be(true)
      end

      it 'returns false for a dataset with multiple rows' do
        DB[:table].multi_insert([{ column: 1 }, { column: 2 }])

        expect(DB[:table].count_equals?(1)).to be(false)
      end

      it 'generates correct SQL' do
        db = Sequel.mock.extension(:count_comparisons)

        db[:table].count_equals?(1)

        expect(db.sqls).to contain_exactly(
          'SELECT ((EXISTS (SELECT 1 AS one FROM table OFFSET 0)) AND NOT (EXISTS (SELECT 1 AS one FROM table OFFSET 1))) AS v LIMIT 1'
        )
      end
    end

    context 'with `number_of_rows` = 2' do
      it 'returns false for an empty dataset' do
        expect(DB[:table].count_equals?(2)).to be(false)
      end

      it 'returns false for a dataset with one row' do
        DB[:table].insert(column: 1)

        expect(DB[:table].count_equals?(2)).to be(false)
      end

      it 'returns true for a dataset with two rows' do
        DB[:table].multi_insert([{ column: 1 }, { column: 2 }])

        expect(DB[:table].count_equals?(2)).to be(true)
      end

      it 'returns false for a dataset with at least three rows' do
        DB[:table].multi_insert([{ column: 1 }, { column: 2 }, { column: 3 }])

        expect(DB[:table].count_equals?(2)).to be(false)
      end

      it 'generates correct SQL' do
        db = Sequel.mock.extension(:count_comparisons)

        db[:table].count_equals?(2)

        expect(db.sqls).to contain_exactly(
          'SELECT ((EXISTS (SELECT 1 AS one FROM table OFFSET 1)) AND NOT (EXISTS (SELECT 1 AS one FROM table OFFSET 2))) AS v LIMIT 1'
        )
      end
    end

    context 'with an ordered dataset' do
      it 'ignores the ordering' do
        db = Sequel.mock.extension(:count_comparisons)
        dataset = db[:table].order(:column)

        dataset.count_equals?(1)

        expect(db.sqls).to contain_exactly(
          'SELECT ((EXISTS (SELECT 1 AS one FROM table OFFSET 0)) AND NOT (EXISTS (SELECT 1 AS one FROM table OFFSET 1))) AS v LIMIT 1'
        )
      end
    end

    context 'with custom SQL' do
      it 'generates correct SQL' do
        db = Sequel.mock.extension(:count_comparisons)
        dataset = db[:table].with_sql('SELECT 1 UNION SELECT 2')

        dataset.count_equals?(1)

        expect(db.sqls).to contain_exactly(
          'SELECT ((EXISTS (SELECT 1 AS one FROM (SELECT 1 UNION SELECT 2) AS t1 OFFSET 0)) AND NOT (EXISTS (SELECT 1 AS one FROM (SELECT 1 UNION SELECT 2) AS t1 OFFSET 1))) AS v LIMIT 1'
        )
      end

      it 'produces correct result' do
        dataset = DB[:table].with_sql('SELECT 1 UNION SELECT 2')

        expect(dataset.count_equals?(2)).to be(true)
      end
    end

    context 'with an invalid argument' do
      it 'raises ArgumentError' do
        ['foo', nil, 3.14, false, true].each do |invalid_argument|
          expect do
            DB[:table].count_equals?(invalid_argument)
          end.to raise_error(
            ArgumentError,
            "`number_of_rows` must be an Integer, got #{invalid_argument.inspect}"
          )
        end
      end
    end
  end

  describe '#count_greater_than?' do
    context 'with `number_of_rows` below 0' do
      it 'returns true for an empty dataset' do
        expect(DB[:table].count_greater_than?(-1)).to be(true)
      end

      it 'returns true for a dataset with one row' do
        DB[:table].insert(column: 1)

        expect(DB[:table].count_greater_than?(-1)).to be(true)
      end

      it 'returns true for a dataset with multiple rows' do
        DB[:table].multi_insert([{ column: 1 }, { column: 2 }])

        expect(DB[:table].count_greater_than?(-1)).to be(true)
      end

      it 'does not hit the database' do
        db = Sequel.mock.extension(:count_comparisons)

        db[:table].count_greater_than?(-1)

        expect(db.sqls).to be_empty
      end
    end

    context 'with `number_of_rows` = 0' do
      it 'returns false for an empty dataset' do
        expect(DB[:table].count_greater_than?(0)).to be(false)
      end

      it 'returns true for a dataset with one row' do
        DB[:table].insert(column: 1)

        expect(DB[:table].count_greater_than?(0)).to be(true)
      end

      it 'returns true for a dataset with multiple rows' do
        DB[:table].multi_insert([{ column: 1 }, { column: 2 }])

        expect(DB[:table].count_greater_than?(0)).to be(true)
      end

      it 'generates correct SQL' do
        db = Sequel.mock.extension(:count_comparisons)

        db[:table].count_greater_than?(0)

        expect(db.sqls).to contain_exactly('SELECT 1 AS one FROM table LIMIT 1')
      end
    end

    context 'with `number_of_rows` = 1' do
      it 'returns false for an empty dataset' do
        expect(DB[:table].count_greater_than?(1)).to be(false)
      end

      it 'returns false for a dataset with one row' do
        DB[:table].insert(column: 1)

        expect(DB[:table].count_greater_than?(1)).to be(false)
      end

      it 'returns true for a dataset with multiple rows' do
        DB[:table].multi_insert([{ column: 1 }, { column: 2 }])

        expect(DB[:table].count_greater_than?(1)).to be(true)
      end

      it 'generates correct SQL' do
        db = Sequel.mock.extension(:count_comparisons)

        db[:table].count_greater_than?(1)

        expect(db.sqls).to contain_exactly(
          'SELECT 1 AS one FROM table LIMIT 1 OFFSET 1'
        )
      end
    end

    context 'with `number_of_rows` = 2' do
      it 'returns false for an empty dataset' do
        expect(DB[:table].count_greater_than?(2)).to be(false)
      end

      it 'returns false for a dataset with one row' do
        DB[:table].insert(column: 1)

        expect(DB[:table].count_greater_than?(2)).to be(false)
      end

      it 'returns false for a dataset with two rows' do
        DB[:table].multi_insert([{ column: 1 }, { column: 2 }])

        expect(DB[:table].count_greater_than?(2)).to be(false)
      end

      it 'returns true for a dataset with at least three rows' do
        DB[:table].multi_insert([{ column: 1 }, { column: 2 }, { column: 3 }])

        expect(DB[:table].count_greater_than?(2)).to be(true)
      end

      it 'generates correct SQL' do
        db = Sequel.mock.extension(:count_comparisons)

        db[:table].count_greater_than?(2)

        expect(db.sqls).to contain_exactly(
          'SELECT 1 AS one FROM table LIMIT 1 OFFSET 2'
        )
      end
    end

    context 'with an ordered dataset' do
      it 'ignores the ordering' do
        db = Sequel.mock.extension(:count_comparisons)
        dataset = db[:table].order(:column)

        dataset.count_greater_than?(1)

        expect(db.sqls).to contain_exactly(
          'SELECT 1 AS one FROM table LIMIT 1 OFFSET 1'
        )
      end
    end

    context 'with custom SQL' do
      it 'generates correct SQL' do
        db = Sequel.mock.extension(:count_comparisons)
        dataset = db[:table].with_sql('SELECT 1 UNION SELECT 2')

        dataset.count_greater_than?(1)

        expect(db.sqls).to contain_exactly(
          'SELECT 1 AS one FROM (SELECT 1 UNION SELECT 2) AS t1 LIMIT 1 OFFSET 1'
        )
      end

      it 'produces correct result' do
        dataset = DB[:table].with_sql('SELECT 1 UNION SELECT 2')

        expect(dataset.count_greater_than?(1)).to be(true)
      end
    end

    context 'with an invalid argument' do
      it 'raises ArgumentError' do
        ['foo', nil, 3.14, false, true].each do |invalid_argument|
          expect do
            DB[:table].count_greater_than?(invalid_argument)
          end.to raise_error(
            ArgumentError,
            "`number_of_rows` must be an Integer, got #{invalid_argument.inspect}"
          )
        end
      end
    end
  end

  describe '#count_less_than?' do
    context 'with `number_of_rows` below 0' do
      it 'returns false for an empty dataset' do
        expect(DB[:table].count_less_than?(-1)).to be(false)
      end

      it 'returns false for a dataset with one row' do
        DB[:table].insert(column: 1)

        expect(DB[:table].count_less_than?(-1)).to be(false)
      end

      it 'returns false for a dataset with multiple rows' do
        DB[:table].multi_insert([{ column: 1 }, { column: 2 }])

        expect(DB[:table].count_less_than?(-1)).to be(false)
      end

      it 'does not hit the database' do
        db = Sequel.mock.extension(:count_comparisons)

        db[:table].count_less_than?(-1)

        expect(db.sqls).to be_empty
      end
    end

    context 'with `number_of_rows` = 0' do
      it 'returns false for an empty dataset' do
        expect(DB[:table].count_less_than?(0)).to be(false)
      end

      it 'returns false for a dataset with one row' do
        DB[:table].insert(column: 1)

        expect(DB[:table].count_less_than?(0)).to be(false)
      end

      it 'returns false for a dataset with multiple rows' do
        DB[:table].multi_insert([{ column: 1 }, { column: 2 }])

        expect(DB[:table].count_less_than?(0)).to be(false)
      end

      it 'does not hit the database' do
        db = Sequel.mock.extension(:count_comparisons)

        db[:table].count_less_than?(0)

        expect(db.sqls).to be_empty
      end
    end

    context 'with `number_of_rows` = 1' do
      it 'returns true for an empty dataset' do
        expect(DB[:table].count_less_than?(1)).to be(true)
      end

      it 'returns false for a dataset with one row' do
        DB[:table].insert(column: 1)

        expect(DB[:table].count_less_than?(1)).to be(false)
      end

      it 'returns false for a dataset with multiple rows' do
        DB[:table].multi_insert([{ column: 1 }, { column: 2 }])

        expect(DB[:table].count_less_than?(1)).to be(false)
      end

      it 'generates correct SQL' do
        db = Sequel.mock.extension(:count_comparisons)

        db[:table].count_less_than?(1)

        expect(db.sqls).to contain_exactly('SELECT 1 AS one FROM table LIMIT 1')
      end
    end

    context 'with `number_of_rows` = 2' do
      it 'returns true for an empty dataset' do
        expect(DB[:table].count_less_than?(2)).to be(true)
      end

      it 'returns true for a dataset with one row' do
        DB[:table].insert(column: 1)

        expect(DB[:table].count_less_than?(2)).to be(true)
      end

      it 'returns false for a dataset with at least two rows' do
        DB[:table].multi_insert([{ column: 1 }, { column: 2 }])

        expect(DB[:table].count_less_than?(2)).to be(false)
      end

      it 'generates correct SQL' do
        db = Sequel.mock.extension(:count_comparisons)

        db[:table].count_less_than?(2)

        expect(db.sqls).to contain_exactly(
          'SELECT 1 AS one FROM table LIMIT 1 OFFSET 1'
        )
      end
    end

    context 'with an ordered dataset' do
      it 'ignores the ordering' do
        db = Sequel.mock.extension(:count_comparisons)
        dataset = db[:table].order(:column)

        dataset.count_less_than?(2)

        expect(db.sqls).to contain_exactly(
          'SELECT 1 AS one FROM table LIMIT 1 OFFSET 1'
        )
      end
    end

    context 'with custom SQL' do
      it 'generates correct SQL' do
        db = Sequel.mock.extension(:count_comparisons)
        dataset = db[:table].with_sql('SELECT 1 UNION SELECT 2')

        dataset.count_less_than?(2)

        expect(db.sqls).to contain_exactly(
          'SELECT 1 AS one FROM (SELECT 1 UNION SELECT 2) AS t1 LIMIT 1 OFFSET 1'
        )
      end

      it 'produces correct result' do
        dataset = DB[:table].with_sql('SELECT 1 UNION SELECT 2')

        expect(dataset.count_less_than?(2)).to be(false)
      end
    end

    context 'with an invalid argument' do
      it 'raises ArgumentError' do
        ['foo', nil, 3.14, false, true].each do |invalid_argument|
          expect do
            DB[:table].count_less_than?(invalid_argument)
          end.to raise_error(
            ArgumentError,
            "`number_of_rows` must be an Integer, got #{invalid_argument.inspect}"
          )
        end
      end
    end
  end

  describe '#count_at_least?' do
    context 'with `number_of_rows` below 0' do
      it 'returns true for an empty dataset' do
        expect(DB[:table].count_at_least?(-1)).to be(true)
      end

      it 'returns true for a dataset with one row' do
        DB[:table].insert(column: 1)

        expect(DB[:table].count_at_least?(-1)).to be(true)
      end

      it 'returns true for a dataset with multiple rows' do
        DB[:table].multi_insert([{ column: 1 }, { column: 2 }])

        expect(DB[:table].count_at_least?(-1)).to be(true)
      end

      it 'does not hit the database' do
        db = Sequel.mock.extension(:count_comparisons)

        db[:table].count_at_least?(-1)

        expect(db.sqls).to be_empty
      end
    end

    context 'with `number_of_rows` = 0' do
      it 'returns true for an empty dataset' do
        expect(DB[:table].count_at_least?(0)).to be(true)
      end

      it 'returns true for a dataset with one row' do
        DB[:table].insert(column: 1)

        expect(DB[:table].count_at_least?(0)).to be(true)
      end

      it 'returns true for a dataset with multiple rows' do
        DB[:table].multi_insert([{ column: 1 }, { column: 2 }])

        expect(DB[:table].count_at_least?(0)).to be(true)
      end

      it 'does not hit the database' do
        db = Sequel.mock.extension(:count_comparisons)

        db[:table].count_at_least?(0)

        expect(db.sqls).to be_empty
      end
    end

    context 'with `number_of_rows` = 1' do
      it 'returns false for an empty dataset' do
        expect(DB[:table].count_at_least?(1)).to be(false)
      end

      it 'returns true for a dataset with one row' do
        DB[:table].insert(column: 1)

        expect(DB[:table].count_at_least?(1)).to be(true)
      end

      it 'returns true for a dataset with multiple rows' do
        DB[:table].multi_insert([{ column: 1 }, { column: 2 }])

        expect(DB[:table].count_at_least?(1)).to be(true)
      end

      it 'generates correct SQL' do
        db = Sequel.mock.extension(:count_comparisons)

        db[:table].count_at_least?(1)

        expect(db.sqls).to contain_exactly('SELECT 1 AS one FROM table LIMIT 1')
      end
    end

    context 'with `number_of_rows` = 2' do
      it 'returns false for an empty dataset' do
        expect(DB[:table].count_at_least?(2)).to be(false)
      end

      it 'returns false for a dataset with one row' do
        DB[:table].insert(column: 1)

        expect(DB[:table].count_at_least?(2)).to be(false)
      end

      it 'returns true for a dataset with at least two rows' do
        DB[:table].multi_insert([{ column: 1 }, { column: 2 }])

        expect(DB[:table].count_at_least?(2)).to be(true)
      end

      it 'generates correct SQL' do
        db = Sequel.mock.extension(:count_comparisons)

        db[:table].count_at_least?(2)

        expect(db.sqls).to contain_exactly(
          'SELECT 1 AS one FROM table LIMIT 1 OFFSET 1'
        )
      end
    end

    context 'with an ordered dataset' do
      it 'ignores the ordering' do
        db = Sequel.mock.extension(:count_comparisons)
        dataset = db[:table].order(:column)

        dataset.count_at_least?(2)

        expect(db.sqls).to contain_exactly(
          'SELECT 1 AS one FROM table LIMIT 1 OFFSET 1'
        )
      end
    end

    context 'with custom SQL' do
      it 'generates correct SQL' do
        db = Sequel.mock.extension(:count_comparisons)
        dataset = db[:table].with_sql('SELECT 1 UNION SELECT 2')

        dataset.count_at_least?(2)

        expect(db.sqls).to contain_exactly(
          'SELECT 1 AS one FROM (SELECT 1 UNION SELECT 2) AS t1 LIMIT 1 OFFSET 1'
        )
      end

      it 'produces correct result' do
        dataset = DB[:table].with_sql('SELECT 1 UNION SELECT 2')

        expect(dataset.count_at_least?(2)).to be(true)
      end
    end

    context 'with an invalid argument' do
      it 'raises ArgumentError' do
        ['foo', nil, 3.14, false, true].each do |invalid_argument|
          expect do
            DB[:table].count_at_least?(invalid_argument)
          end.to raise_error(
            ArgumentError,
            "`number_of_rows` must be an Integer, got #{invalid_argument.inspect}"
          )
        end
      end
    end
  end

  describe '#count_at_most?' do
    context 'with `number_of_rows` below 0' do
      it 'returns false for an empty dataset' do
        expect(DB[:table].count_at_most?(-1)).to be(false)
      end

      it 'returns false for a dataset with one row' do
        DB[:table].insert(column: 1)

        expect(DB[:table].count_at_most?(-1)).to be(false)
      end

      it 'returns false for a dataset with multiple rows' do
        DB[:table].multi_insert([{ column: 1 }, { column: 2 }])

        expect(DB[:table].count_at_most?(-1)).to be(false)
      end

      it 'does not hit the database' do
        db = Sequel.mock.extension(:count_comparisons)

        db[:table].count_at_most?(-1)

        expect(db.sqls).to be_empty
      end
    end

    context 'with `number_of_rows` = 0' do
      it 'returns true for an empty dataset' do
        expect(DB[:table].count_at_most?(0)).to be(true)
      end

      it 'returns false for a dataset with one row' do
        DB[:table].insert(column: 1)

        expect(DB[:table].count_at_most?(0)).to be(false)
      end

      it 'returns false for a dataset with multiple rows' do
        DB[:table].multi_insert([{ column: 1 }, { column: 2 }])

        expect(DB[:table].count_at_most?(0)).to be(false)
      end

      it 'generates correct SQL' do
        db = Sequel.mock.extension(:count_comparisons)

        db[:table].count_at_most?(0)

        expect(db.sqls).to contain_exactly('SELECT 1 AS one FROM table LIMIT 1')
      end
    end

    context 'with `number_of_rows` = 1' do
      it 'returns true for an empty dataset' do
        expect(DB[:table].count_at_most?(1)).to be(true)
      end

      it 'returns true for a dataset with one row' do
        DB[:table].insert(column: 1)

        expect(DB[:table].count_at_most?(1)).to be(true)
      end

      it 'returns false for a dataset with multiple rows' do
        DB[:table].multi_insert([{ column: 1 }, { column: 2 }])

        expect(DB[:table].count_at_most?(1)).to be(false)
      end

      it 'generates correct SQL' do
        db = Sequel.mock.extension(:count_comparisons)

        db[:table].count_at_most?(1)

        expect(db.sqls).to contain_exactly(
          'SELECT 1 AS one FROM table LIMIT 1 OFFSET 1'
        )
      end
    end

    context 'with `number_of_rows` = 2' do
      it 'returns true for an empty dataset' do
        expect(DB[:table].count_at_most?(2)).to be(true)
      end

      it 'returns true for a dataset with one row' do
        DB[:table].insert(column: 1)

        expect(DB[:table].count_at_most?(2)).to be(true)
      end

      it 'returns true for a dataset with two rows' do
        DB[:table].multi_insert([{ column: 1 }, { column: 2 }])

        expect(DB[:table].count_at_most?(2)).to be(true)
      end

      it 'returns false for a dataset with at least three rows' do
        DB[:table].multi_insert([{ column: 1 }, { column: 2 }, { column: 3 }])

        expect(DB[:table].count_at_most?(2)).to be(false)
      end

      it 'generates correct SQL' do
        db = Sequel.mock.extension(:count_comparisons)

        db[:table].count_at_most?(2)

        expect(db.sqls).to contain_exactly(
          'SELECT 1 AS one FROM table LIMIT 1 OFFSET 2'
        )
      end
    end

    context 'with an ordered dataset' do
      it 'ignores the ordering' do
        db = Sequel.mock.extension(:count_comparisons)
        dataset = db[:table].order(:column)

        dataset.count_at_most?(1)

        expect(db.sqls).to contain_exactly(
          'SELECT 1 AS one FROM table LIMIT 1 OFFSET 1'
        )
      end
    end

    context 'with custom SQL' do
      it 'generates correct SQL' do
        db = Sequel.mock.extension(:count_comparisons)
        dataset = db[:table].with_sql('SELECT 1 UNION SELECT 2')

        dataset.count_at_most?(1)

        expect(db.sqls).to contain_exactly(
          'SELECT 1 AS one FROM (SELECT 1 UNION SELECT 2) AS t1 LIMIT 1 OFFSET 1'
        )
      end

      it 'produces correct result' do
        dataset = DB[:table].with_sql('SELECT 1 UNION SELECT 2')

        expect(dataset.count_at_most?(1)).to be(false)
      end
    end

    context 'with an invalid argument' do
      it 'raises ArgumentError' do
        ['foo', nil, 3.14, false, true].each do |invalid_argument|
          expect do
            DB[:table].count_at_most?(invalid_argument)
          end.to raise_error(
            ArgumentError,
            "`number_of_rows` must be an Integer, got #{invalid_argument.inspect}"
          )
        end
      end
    end
  end
end
