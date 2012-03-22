$LOAD_PATH << "lib"

require 'suitecsv.rb'
require 'test/unit'

class TestSuiteCSV < Test::Unit::TestCase

	def test_init
		# Test Initialization of SuiteCSV Class
		assert_nothing_raised() { SuiteCSV.new "sample1.csv"}
		assert_raise(ArgumentError) { SuiteCSV.new }
		assert_raise(ArgumentError) { SuiteCSV.new "sample1.csv", "sample2.csv"}

		# MergeCSV
		assert_nothing_raised() { MergeCSV.new "sample1.csv", ["internal id", "last name"]}
		assert_raise(ArgumentError) { MergeCSV.new }
		assert_raise(ArgumentError) { MergeCSV.new "sample1.csv"}
		assert_raise(ArgumentError) { MergeCSV.new "sample1.csv", ["internal id", "last name"], "sample2.csv"}

		# JoinCSV
		assert_nothing_raised() { JoinCSV.new "sample1.csv", ["internal id", "last name"]}
		assert_raise(ArgumentError) { JoinCSV.new }
		assert_raise(ArgumentError) { JoinCSV.new "sample1.csv"}
		assert_raise(ArgumentError) { JoinCSV.new "sample1.csv", ["internal id", "last name"], "sample2.csv"}
	end

end
