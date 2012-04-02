$LOAD_PATH << "../lib"

require 'suitecsv.rb'
require 'test/unit'

class TestMergeCSV < Test::Unit::TestCase

	def test_init
		assert_nothing_raised { MergeCSV.new "sample1.csv", ["Internal ID", "Last Name"]}
		assert_raise(ArgumentError) { MergeCSV.new }
		assert_raise(ArgumentError) { MergeCSV.new "sample1.csv"}
		assert_raise(ArgumentError) { MergeCSV.new "sample1.csv", ["Internal ID", "Last Name"], "sample2.csv"}
		assert_raise(RuntimeError) { MergeCSV.new "sample1.csv", ["Internal ID", "fake_key"]}
	end

	def test_merge
		assert_nothing_raised do
			@sample1 = MergeCSV.new "sample1.csv", ["Internal ID", "Last Name"]
		 	@sample2 = SuiteCSV.new "sample2.csv"
		 	@sample1.merge @sample2
		 	@sample1.write "sample1-2_merge.csv"
		end

		# NEED A TEST OF AN ATTEMPTED MERGE WHERE COLUMNS DON'T EXIST IN DESTINATION & VICE VERSA
	end
end