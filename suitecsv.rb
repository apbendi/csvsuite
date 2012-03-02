require 'csv'

# This is a test!

class SuiteCSV < CSV
	
	attr_reader :matrix
	
	# Only accept filenames, not strings, when defining a CSV
	# Always require headers to be true
	# Read the file & load it into a matrix
	def initialize(filename)
		super File.new(filename), {:headers => true}
		@matrix = self.read
	end
	
	## THIS SHOULD BE CLEANER IF WE CORRECTLY LEVERAGE THE 
	## CSV::TABLE & CSV::ROW classes
	def write(filename)
		
		out_file = File.new filename, "w"
		out_file.puts @headers.join(",")
		
		@matrix.each do |row|
			out_file.puts row.to_csv
		end
		
		out_file.close
	end
	
end

class MergeCSV < SuiteCSV

	attr_reader :keys
	
	def initialize(filename, keys)
		@keys = keys
		super(filename)
		
		# Ensure the CSV has a header for each defined key
		@keys.each do |key|
			if not @headers.index(key)
				raise "ERROR: could not find header for key: #{key}"
		  	end
		end
	end
	
	# Take another CSV & Merge it into this CSV.
	# Afterwards this CSV will be the combination of the two
	# without duplicates, based on comparison of keys
	def merge(other)
		
		# Ensure the other CSV has the same headers
		@headers.each do |header|
			if not other.headers.index(header)
				$stdout.puts "Warning: could not find header: #{header}"
				return false
			end
		end
		
		# Go through each row in the other CSV
		other.matrix.each do |other_row|
		
			# init the var to track whether this row is already present
			already_present = false
			
			# Go through each row in myself, see if the other's row is here
			@matrix.each do |my_row|
			
				# If the keys match this row is present - stop checking
				if keys_match?(my_row, other_row)
					already_present = true
					break
				end
			end
			
			# Add this row to th
			if not already_present
				$stdout.puts "Adding row: #{other_row}"
				push_row other_row
			end
		end

	end
	
	###########################
	## BEGIN PRIVATE METHODS ##
	###########################
	private
	
	# Do the keys from my_row match the key from other_row?
	def keys_match?(my_row, other_row)
		
		# If each value at this key doesn't match, return false
		@keys.each do |key|
			if not my_row[key] =~ /^#{other_row[key]}$/i
				return false
			end
		end
		
		# If we checked values at each key w/o mismatch, its the same
		return true
	end
	
	# Put the other row into our CSV, matching headers
	def push_row(other_row)
		# initialize the new array
		new_row = Array.new(@headers.length)
		
		# Iterate headers, building our new row
		0.upto @headers.length-1 do |index|		
			
			# Put the value into the corresponding column in our CSV
			new_row[index] = other_row[ @headers[index] ]
		end
		
		# Add this row into our matrix
		@matrix<< new_row
	end
end

# Take two CSVs and produce a result that is the overlap of
# the two w/o repeats
class JoinCSV < SuiteCSV
	
	attr_reader :keys
	
	def initialize(filename, keys)
		@keys = keys
		super(filename)
	end
end

test = CSV.open("sample2.csv")
puts test.read

#sample1 = MergeCSV.new("sample1.csv", ["internal id", "last name"])
#sample2 = SuiteCSV.new("sample2.csv")
#rented = MergeCSV.new("../rented_us_pastors_splitzip.csv", ["l_name", "split_zip"])
#chads = SuiteCSV.new("../chad_us_pastors_splitzip.csv")

#rented = MergeCSV.new("../rented_metuchen_etc_pastors_splitzip.csv", ["l_name", "split_zip"])
#netsuite = SuiteCSV.new("../netsuite_metuchen_etc_pastors_splitzip.csv")

#sample1.merge sample2
#sample1.write "results.csv"

#rented.merge netsuite
#rented.write "results.csv"

#puts sample1.headers

#sample1.matrix.each do |row|
#	puts row
#end
