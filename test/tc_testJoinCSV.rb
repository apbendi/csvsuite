$LOAD_PATH << "../lib"

require 'suitecsv.rb'
require 'test/unit'

class TestJoinCSV < Test::Unit::TestCase

	def setup
		@sample1 = JoinCSV.new "sample1.csv", ["Internal ID", "Last Name"]
		@sample2 = JoinCSV.new "sample2.csv", ["Internal ID", "Last Name"]
		@full = JoinCSV.new "us_presidents_full.csv", ["Wikipedia Entry"]
	end

	def teardown
		@sample1 = @sample2 = @full = nil
	end

	def test_init
		assert_nothing_raised { JoinCSV.new "sample1.csv", ["Internal ID", "Last Name"]}
		assert_raise(ArgumentError) { JoinCSV.new }
		assert_raise(ArgumentError) { JoinCSV.new "sample1.csv"}
		assert_raise(ArgumentError) { JoinCSV.new "sample1.csv", ["Internal ID", "Last Name"], "sample2.csv"}
		assert_raise(RuntimeError) { JoinCSV.new "sample1.csv", ["Internal ID", "fake_key"]}
	end

	def test_join

		# Ensure a join where other doesn't have key causes a raise
		assert_raise(RuntimeError) { @full.join @sample1 }

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

		# Ensure an unjoin where other doesn't have key causes a raise
		assert_raise(RuntimeError) { @full.unjoin @sample1 }

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

		# If the column to bring is not present, this should cause an error
		assert_raise(RuntimeError) { @sample1.bring @sample2, ["fake_column"] }

		# If the column to bring is already present, this should cause an error
		assert_raise(RuntimeError) { @sample1.bring @sample2, ["Party"] }

		# Ensure a bring where other doesn't have key causes a raise
		assert_raise(RuntimeError) { @full.bring @sample1, ["From Sample"] }

		# Perform a Bring and verify the results
		assert_nothing_raised {
			@sample1.bring @full, ["Wikipedia Entry"]
			@sample1.write "sample1-bring.csv"

			# Iterate each row in the new CSV looking for a valid Wikipedia entry
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