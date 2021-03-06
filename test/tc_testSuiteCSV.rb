$LOAD_PATH << "../lib"

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
	end

	def test_read
		# Initialize a (stardard Ruby) CSV version of this file
		csv_sample1 = CSV.new File.new("sample1.csv"), {:headers => true}
		table_sample1 = csv_sample1.read

		# Ensure  SuiteCSV has been created
		assert_not_nil @sample1

		# Ensure headers have been correctly read
		assert @sample1.headers.index("Internal ID"), "Header not found: internal id"
		assert @sample1.headers.index("Last Name"), "Header not found: last name"
		assert @sample1.headers.index("Zip"), "Header not found: zip"
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
			csv_sample1_out = CSV.new File.new("sample1_out.csv"), {:headers => true}
			table_sample1_out = csv_sample1_out.read
		end

		# Ensure output file is the same as the input file
		assert_equal table_sample1, table_sample1_out, "Written File does not match File read"
	end

	def test_split_zip
		# Ensure invalid column arguments produce RuntimeErrors
		assert_raise(RuntimeError, "False Zip Column did not cause Error") { @sample1.split_zip "fake_zip", "slit_zip" }
		assert_raise(RuntimeError, "Provided existing Column w/o Error") { @sample1.split_zip "Zip", "Internal ID" }

		# Split the zip w/ no errors
		assert_nothing_raised { @sample1.split_zip "Zip", "split_zip"}

		# Make sure split_zip has been added to headers
		assert @sample1.headers.index "split_zip"

		# Iterate each row and ensure split_zip has worked correctly
		assert_nothing_raised(RuntimeError) do
			@sample1.each do |row|
				if not row["Zip"].split("-").first == row["split_zip"]
					raise "Zip & split_zip columns don't match at #{row.to_s}"
				end
			end
		end

	end

	def test_excelify
		# Ensure invalid column arguments produce RuntimeErrors
		assert_raise(RuntimeError, "False Column to excelify did not cause Error") { @sample1.excelify("fake_zip") }

		# Excelify the column w/ no errors
		assert_nothing_raised { @sample1.excelify "Zip" }

		# Iterate each zip row & ensure its been excelified
		assert_nothing_raised(RuntimeError) do
			@sample1.each do |row|
				if not row["Zip"].match(/^\|EXCEL_OPEN\|.*\|EXCEL_CLOSE\|$/)
					raise "Row was not excelified: #{row.to_s}"
				end
			end
		end

		# Write the file out
		assert_nothing_raised("Could not write after excelify") { @sample1.write "sample1_excelified.csv" }

		# Read the file we just wrote and look for the excelification
		assert_nothing_raised do
			File.open("sample1_excelified.csv", "r") do |handle|
				first_line = true
				while line = handle.gets
					if first_line
						first_line = false
					elsif not line.match(/=\".*\"/) #"
						raise "Line in file not excelified after write: #{line}"
					end
				end
			end
		end
	end

end
