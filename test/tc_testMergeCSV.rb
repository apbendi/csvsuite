$LOAD_PATH << "../lib"

require 'suitecsv.rb'
require 'test/unit'

class TestMergeCSV < Test::Unit::TestCase

	def setup

	end

	def teardown

	end

	def test_init
		assert_nothing_raised { MergeCSV.new "sample1.csv", ["Internal ID", "Last Name"]}
		assert_raise(ArgumentError) { MergeCSV.new }
		assert_raise(ArgumentError) { MergeCSV.new "sample1.csv"}
		assert_raise(ArgumentError) { MergeCSV.new "sample1.csv", ["Internal ID", "Last Name"], "sample2.csv"}
		assert_raise(RuntimeError) { MergeCSV.new "sample1.csv", ["Internal ID", "fake_key"]}
	end

	def test_merge

	end
end