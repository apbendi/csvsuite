$LOAD_PATH << "../lib"

require 'suitecsv.rb'
require 'test/unit'

class TestJoinCSV < Test::Unit::TestCase

	def setup
		@sample1 = JoinCSV.new "sample1.csv", ["Internal ID", "Last Name"]
		@sample2 = JoinCSV.new "sample2.csv", ["Internal ID", "Last Name"]
	end

	def teardown
		@sample1 = @sample2 = nil
	end

	def test_init
		assert_nothing_raised { JoinCSV.new "sample1.csv", ["Internal ID", "Last Name"]}
		assert_raise(ArgumentError) { JoinCSV.new }
		assert_raise(ArgumentError) { JoinCSV.new "sample1.csv"}
		assert_raise(ArgumentError) { JoinCSV.new "sample1.csv", ["Internal ID", "Last Name"], "sample2.csv"}
		assert_raise(RuntimeError) { JoinCSV.new "sample1.csv", ["Internal ID", "fake_key"]}
	end

	def test_join

		# TEST COLUMN MISMATCHES

		# Perform a Join and then verify the results
		assert_nothing_raised { 
			@sample1.join @sample2
			@sample1.write "sample1-2_join.csv"
			
			# Iterate each row in the new CSV & ensure its ID exists both files
			joined = SuiteCSV.new "sample1-2_join.csv"
			joined.each do |row|
				id = row["Internal ID"]
				if not ( present_infile?(id, "sample1.csv") \
					and present_infile?(id, "sample2.csv") )

					raise "Row in Join not found in both files: #{row.to_s}"
				end
			end

		}
	end

	def test_unjoin

		# TEST COLUMN MISMATCHES

		# Perform an Unjoin and then verify the results
		assert_nothing_raised {
			@sample1.unjoin @sample2
			@sample1.write "sample1-2_unjoin.csv"

			# Iterate each row in the new CSV & ensure its ID does not exist in the other file
			unjoined = SuiteCSV.new "sample1-2_unjoin.csv"
			unjoined.each do |row|
				id = row["Internal ID"]
				if present_infile?(id, "sample2.csv")

					raise "Row in Unjoin found in other file: #{row.to_s}"
				end
			end
		}

	end

	def test_bring

		# TEST COLUMN MISMATCHES

		assert_nothing_raised {
			full = SuiteCSV.new "us_presidents_full.csv"
			@sample1.bring full, ["Wikipedia Entry"]
			@sample1.write "sample1-bring.csv"


			bring = SuiteCSV.new "sample1-bring.csv"
			bring.each do |row|
				if not row["Wikipedia Entry"]
					raise "Wikipedia Entry not brought for row: #{row.to_s}"
				elsif not row["Wikipedia Entry"].match(/^http:\/\/en\.wikipedia\.org\/wiki/)
					raise "Brought Wikipedia Entry appears malformed for #{row.to_s}"
				end
			end
		}
	end

	private
	#######

	# Given an ID string, does this file contain a line that starts with this ID
	def present_infile?(id, file)
		File.open file do |fl|
			while line = fl.gets
				if line.match(/^#{id},/)
					return true
				end
			end
		end

		return false
	end
end