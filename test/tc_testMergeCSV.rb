$LOAD_PATH << "../lib"

require 'suitecsv.rb'
require 'test/unit'

class TestMergeCSV < Test::Unit::TestCase

	def test_init
		assert_nothing_raised { MergeCSV.new "sample1.csv", ["internal id", "last name"]}
		assert_raise(ArgumentError) { MergeCSV.new }
		assert_raise(ArgumentError) { MergeCSV.new "sample1.csv"}
		assert_raise(ArgumentError) { MergeCSV.new "sample1.csv", ["internal id", "last name"], "sample2.csv"}
		assert_raise(RuntimeError) { MergeCSV.new "sample1.csv", ["internal id", "fake_key"]}
	end
end