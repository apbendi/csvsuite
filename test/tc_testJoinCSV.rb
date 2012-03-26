$LOAD_PATH << "../lib"

require 'suitecsv.rb'
require 'test/unit'

class TestJoinCSV < Test::Unit::TestCase

	def test_init
		assert_nothing_raised { JoinCSV.new "sample1.csv", ["internal id", "last name"]}
		assert_raise(ArgumentError) { JoinCSV.new }
		assert_raise(ArgumentError) { JoinCSV.new "sample1.csv"}
		assert_raise(ArgumentError) { JoinCSV.new "sample1.csv", ["internal id", "last name"], "sample2.csv"}
		assert_raise(RuntimeError) { JoinCSV.new "sample1.csv", ["internal id", "fake_key"]}
	end
end