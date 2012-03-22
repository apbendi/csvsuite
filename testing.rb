$LOAD_PATH << "lib"

require 'suitecsv.rb'
require 'test/unit'

class TestSuiteCSV < Test::Unit::TestCase

	def setup
		@sample1 = SuiteCSV.new "sample1.csv"
	end

	def teardown
		@sample1 = nil
	end

	def test_init
		# Test Initialization of SuiteCSV Class
		assert_nothing_raised { SuiteCSV.new "sample1.csv"}
		assert_raise(ArgumentError) { SuiteCSV.new }
		assert_raise(ArgumentError) { SuiteCSV.new "sample1.csv", "sample2.csv"}

		# MergeCSV
		assert_nothing_raised { MergeCSV.new "sample1.csv", ["internal id", "last name"]}
		assert_raise(ArgumentError) { MergeCSV.new }
		assert_raise(ArgumentError) { MergeCSV.new "sample1.csv"}
		assert_raise(ArgumentError) { MergeCSV.new "sample1.csv", ["internal id", "last name"], "sample2.csv"}

		# JoinCSV
		assert_nothing_raised { JoinCSV.new "sample1.csv", ["internal id", "last name"]}
		assert_raise(ArgumentError) { JoinCSV.new }
		assert_raise(ArgumentError) { JoinCSV.new "sample1.csv"}
		assert_raise(ArgumentError) { JoinCSV.new "sample1.csv", ["internal id", "last name"], "sample2.csv"}
	end

	def test_read

		# Initialize a (stardard Ruby) CSV version of this file
		csv_sample1 = CSV.new File.new("sample1.csv"), {:headers => true}
		table_sample1 = csv_sample1.read

		# Ensure  SuiteCSV has been created
		assert_not_nil @sample1

		# Ensure headers have been correctly read
		assert @sample1.headers.index("internal id"), "Header not found: internal id"
		assert @sample1.headers.index("last name"), "Header not found: last name"
		assert @sample1.headers.index("zip"), "Header not found: zip"
		assert  ( not @sample1.headers.index("Fake_Header") ), "Fake_Header returning true"

		# SuiteCSV headers should match CSV headers
		assert ( @sample1.headers == table_sample1.headers ), "SuiteCSV Headers do not match CSV Headers\n" +\
			"SuiteCSV: #{@sample1.headers}\nCSV: #{table_sample1.headers}"

		# Ensure that all of our rows match 
		assert_equal @sample1, table_sample1, "SuiteCSV does not match results from CSV"
	end

	def test_write
		# Var Declaration
		csv_sample1_out, table_sample1_out = nil

		# Initialize a (stardard Ruby) CSV version of this file
		csv_sample1 = CSV.new File.new("sample1.csv"), {:headers => true}
		table_sample1 = csv_sample1.read

		# Ensure  SuiteCSV has been created
		assert_not_nil @sample1

		# Write to a new path and ensure nothing went wrong
		assert_nothing_raised { @sample1.write "sample1_out.csv" }

		# Initialize a CSV version of the file we just wrote
		assert_nothing_raised("Written File could not be read by CSV") do
			csv_sample1_out = CSV.new File.new("sample2.csv"), {:headers => true}
			table_sample1_out = csv_sample1_out.read
		end

		# Ensure output file is the same as the input file
		assert_equal table_sample1, table_sample1_out, "Written File does not match File read"
	end

end
