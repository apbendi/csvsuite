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

	def test_read

		# Declare Var
		sample1 = nil

		# Initialize a (stardard Ruby) CSV version of this file
		csv_sample1 = CSV.new File.new("sample1.csv"), {:headers => true}
		table_sample1 = csv_sample1.read

		# Successfully Initialize SuiteCSV
		assert_nothing_raised do
			sample1 = SuiteCSV.new "sample1.csv"
		end

		# Ensure  SuiteCSV has been created
		assert_not_nil sample1

		# Ensure headers have been correctly read
		assert sample1.headers.index("internal id"), "Header not found: internal id"
		assert sample1.headers.index("last name"), "Header not found: last name"
		assert sample1.headers.index("zip"), "Header not found: zip"
		assert  ( not sample1.headers.index("Fake_Header") ), "Fake_Header returning true"

		# SuiteCSV headers should match CSV headers
		assert ( sample1.headers == table_sample1.headers ), "SuiteCSV Headers do not match CSV Headers\n" +\
			"SuiteCSV: #{sample1.headers}\nCSV: #{table_sample1.headers}"

		# Ensure that all of our rows match 
		assert_block("SuiteCSV Rows do not match CSV Rows") do
			all_equal = true

			# Iterate and compare all rows
			 0.upto sample1.length-1 do |index|
			 	if not ( sample1[index] == table_sample1[index] )
			 		all_equal = false
			 		break
			 	end
			 end
 
			 all_equal

		end
	end

	def test_write
		
	end

end
