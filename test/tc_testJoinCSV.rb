$LOAD_PATH << "../lib"

require 'suitecsv.rb'
require 'test/unit'

class TestJoinCSV < Test::Unit::TestCase

	def setup

	end

	def teardown

	end

	def test_init
		assert_nothing_raised { JoinCSV.new "sample1.csv", ["Internal ID", "Last Name"]}
		assert_raise(ArgumentError) { JoinCSV.new }
		assert_raise(ArgumentError) { JoinCSV.new "sample1.csv"}
		assert_raise(ArgumentError) { JoinCSV.new "sample1.csv", ["Internal ID", "Last Name"], "sample2.csv"}
		assert_raise(RuntimeError) { JoinCSV.new "sample1.csv", ["Internal ID", "fake_key"]}
	end

	def test_join

	end

	def test_unjoin

	end

	def test_bring

	end
end