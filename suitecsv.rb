require 'csv'

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

# Take two CSVs and produce a result that is the combination
# of the two w/o repeats
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
	
	def merge(other)
		
		# Ensure the other CSV has the same headers
		@headers.each do |header|
			if not other.headers.index(header)
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
				if keys_match?(my_row, other_row, other.headers)
					already_present = true
					break
				end
			end
			
			# Add this row to th
			if not already_present
				$stdout.puts "Adding row: #{other_row}"
				push_row(other_row, other.headers)
			end
		end

	end
	
	## BEGIN PRIVATE METHODS ##
	private
	
	# Do the keys from my_row match the key from other_row?
	def keys_match?(my_row, other_row, other_headers)
		@keys.each do |key|
			# Get each index of this key
			my_index = @headers.index(key)
			other_index = other_headers.index(key)
			
			# If each value at this key doesn't match, return false
			if not my_row[my_index] =~ /^#{other_row[other_index]}$/i
				return false
			end
		end
		
		# If we checked values at each key w/o mismatch, its the same
		return true
	end
	
	# Put the other row into our CSV, matching headers
	def push_row(other_row, other_headers)
		# initialize the new array
		new_row = Array.new(@headers.length)
		
		# Iterate headers, building our new row
		0.upto @headers.length-1 do |my_index|		
			# Find the index of this column in the other CSV
			other_index = other_headers.index( @headers[my_index] )
			
			# Put the value into the corresponding column in our CSV
			new_row[my_index] = other_row[other_index]
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

sample1 = MergeCSV.new("sample1.csv", ["internal id", "last name"])
sample2 = SuiteCSV.new("sample2.csv")

sample1.merge sample2
sample1.write "results.csv"

#puts sample1.headers

#sample1.matrix.each do |row|
#	puts row
#end
