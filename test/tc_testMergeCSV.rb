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
			sample1 = MergeCSV.new "sample1.csv", ["Internal ID", "Last Name"]
		 	sample2 = SuiteCSV.new "sample2.csv"
		 	sample1.merge sample2
		 	sample1.write "sample1-2_merge.csv"
		end

		# Initialize a CVS versions of the answer & our result
		csv_1_2_merge 	= CSV.new File.new("sample1-2_merge.csv"), {:headers => true}
		table_1_2_merge = csv_1_2_merge.read
		csv_1_2_ans 	= CSV.new File.new("sample1-2_merge_ans.csv"), {:headers => true}
		table_1_2_ans 	= csv_1_2_ans.read

		# Ensure our results match the known, correct answer
		assert_equal table_1_2_merge, table_1_2_ans, "Merge did not produce expected results"
	end

	def test_merge2
		sample1 = MergeCSV.new "sample1.csv", ["Internal ID", "Last Name"]
		full 	= MergeCSV.new "us_presidents_full.csv", ["Internal ID", "Last Name"]
		full.headers<< "From Sample" # Add this so we don't cause a merge error for mismatched cols

		# If the source CSV lacks columns in the destination, there should be an error
		assert_raise(RuntimeError) { full.merge sample1 }

		assert_nothing_raised() do
			sample1.merge full
			sample1.write "sample1-full_merge.csv"
		end

		# Initialize a CVS versions of the answer & our result
		csv_1_full_merge 	= CSV.new File.new("sample1-full_merge.csv"), {:headers => true}
		table_1_full_merge 	= csv_1_full_merge.read
		csv_1_full_ans 		= CSV.new File.new("sample1-full_merge_ans.csv"), {:headers => true}
		table_1_full_ans 	= csv_1_full_ans.read
  
		# Ensure our results match the known, correct answer
		assert_equal table_1_full_ans, table_1_full_merge, "Merge did not produce expected results"
	end
end