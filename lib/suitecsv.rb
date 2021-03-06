require 'csv'

module CSValidation
	# Ensure my CSV actually has the keys assigned it
	def key_check
		@keys.each do |key|
			if not @headers.index(key)
				raise "ERROR: could not find header for key: #{key}"
		  	end
		end
	end

	# Does the other CSV have key columns matching our key?
	def has_keys?(other)
		@keys.each do |key|
			if not other.headers.index(key)
				return false
			end
		end
	end
	
	# Is this row present in the other CSV?
	def also_present?(row, other)
	
		other.each do |other_row|
			if keys_match?(row, other_row)
				return other_row
			end
		end
		
		return false
	end
	
	# Do the keys from my_row match the key from other_row?
	def keys_match?(my_row, other_row)
		# Ensure arguments are not nil
		if not (my_row and other_row)
			return nil
		end
		
		# If each value at this key doesn't match, return false
		@keys.each do |key|
			if not my_row[key].to_s =~ /^#{other_row[key].to_s}$/i
				return false
			end
		end
		
		#$stdout.puts "Match: " + my_row["split_zip"] + " AND " + other_row["split_zip"]
		
		# If we checked values at each key w/o mismatch, its the same
		return true
	end

	def already_present?(other_row)
		# Go through each row in myself, see if the other's row is here
		@matrix.each do |my_row|
			# If the keys match this row is present - stop checking
			if keys_match?(my_row, other_row)
				return true
			end
		end

		return false
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

class SuiteCSV
	# Re-map appropriate methods to the internal table
	extend Forwardable
	def_delegators :@matrix, :<<, :[], :==, :each, :length, :delete
	
	#attr_reader :headers
	attr_accessor :headers
	
	# Only accept filenames, not strings, when defining a CSV
	# Always require headers to be true
	# Read the file & load it into a matrix
	def initialize(filename)
		myCSV = CSV.new File.new(filename), {:headers => true}
		@matrix = myCSV.read
		@headers = @matrix.headers
	end
	
	# Given the current zip column and the name of a new column
	# Split the zip column values on '-' and put the first half
	# in the new column
	def split_zip(zip_col, new_col)
	
		# Make sure zip column does exist
		if not @headers.index(zip_col)
			raise "ERROR- couldn't find indicated zip column: #{zip_col}"
		end
		
		# Make sure new column doesn't exist
		if @headers.index(new_col)
			raise "ERROR- new column already exists; overwrite not permitted"
		end
		
		# Add the new column to the headers
		@headers<< new_col
		
		# Split each zip and add it to the new column
		@matrix.each do |row|
			if row[zip_col]
				first_half = row[zip_col].split(/-/).first
			end
			row<< [new_col, first_half]
		end
	end
	
	# Add an "=" sign, double quotes & a space to each value in col
	# This is the only reliable way to force Excel to treat the
	# column as a string & prevent loss of leading zeros in things like
	# zip codes.  Since these quotes would be escaped when converted to_csv,
	# we'll add open & close tags and sub them at write time
	def excelify(col)
		
		# Make sure the column exists
		if not @headers.index(col)
			raise "ERROR- can not excelify column #{col}; not found!"
		end
		
		@matrix.each do |row|
			# Ignore the case when the cell value is nil
			if row[col]
				row[col] = "|EXCEL_OPEN|" + row[col] + "|EXCEL_CLOSE|"
			end
		end
		
		# Set to true so the write method knows to sub tags
		@excelified = true
	end
	
	def write(filename)
		
		out_file = File.new filename, "w"
		out_file.puts @headers.to_csv
		
		@matrix.each do |row|
			# ignore nil row
			if row
				if @excelified
					# Swap out open close tags to prevent escaping
					out_file.puts row.to_csv.gsub("|EXCEL_OPEN|", "=\"").gsub("|EXCEL_CLOSE|", " \"")
				else
					out_file.puts row.to_csv
				end
			end
		end
		
		out_file.close
	end
	
end

# Not happy about making this a class- but lets face it, we need to rethink
# the whole archictecture of this thing- so this will do for now.
class DedupeCSV < SuiteCSV
	attr_reader :keys

	def initialize(filename, keys)
		@keys = keys
		super(filename)
		key_check
	end

	def dedupe
		comp_matrix = Array.new

		# Because .length will change as we delete, we must save ahead of time
		# and also track the number of rows we've removed
		length = @matrix.length
		counter = removed_count = 0
		
		# Iterate our matrix removing rows not present in the other CSV
		0.upto length do |index|
			counter += 1
			# nil row check
			if not @matrix[index-removed_count]
				next
			end
			
			# If this row is NOT also present in other, delete it here
			if also_present?(@matrix[index-removed_count], comp_matrix)\

				#puts "Delete: #{@matrix[index-removed_count].to_s}"

				@matrix.delete(index-removed_count)
				removed_count += 1
			else
				comp_matrix.push @matrix[index-removed_count]
			end

			if counter % 500 == 0
				$stdout.puts counter
			end
		end

		return removed_count
	end

	private
	#######
	include CSValidation
end

class MergeCSV < SuiteCSV

	attr_reader :keys
	
	def initialize(filename, keys)
		@keys = keys
		super(filename)
		key_check
	end
	
	# Take another CSV & Merge it into this CSV.
	# Afterwards this CSV will be itself with the addition of the second,
	# excluding duplicates, based on comparison of keys
	def merge(other)
		# Ensure the other CSV has the same headers
		@headers.each do |header|
			if not other.headers.index(header)
				raise "ERROR: headers do not match, could not find: #{header}"
			end
		end

		# Initialize variable to process rows processed & added
		counter = added = 0
		
		# Go through each row in the other CSV
		other.each do |other_row|
			counter += 1
			
			# Add this row to our table
			if not already_present?(other_row)
				push_row other_row
				added += 1
			end

			if counter % 500 == 0
				$stdout.puts counter
			end
		end

		return added
	end

	private
	#######
	include CSValidation
end

class JoinCSV < SuiteCSV
	
	attr_reader :keys
	
	def initialize(filename, keys)
		@keys = keys
		super(filename)
		key_check
	end
	
	# Take two CSVs and produce a result that is the overlap of
	# the two w/o repeats
	def join(other)
		
		# Ensure the other CSV has the keys present
		if not has_keys?(other)
			raise "ERROR: Could not find all key columns #{@keys.to_s} in other CSV"
		end
		
		# Because .length will change as we delete, we must save ahead of time
		# and also track the number of rows we've removed
		length = @matrix.length
		removed_count = 0
		
		# Iterate our matrix removing rows not present in the other CSV
		0.upto length do |index|
			# nil row check
			if not @matrix[index-removed_count]
				next
			end
			
			# If this row is NOT also present in other, delete it here
			if not also_present?(@matrix[index-removed_count], other)
				@matrix.delete(index-removed_count)
				removed_count += 1
			end
		end
	end
	
	# Remove all rows in this CSV that _are_ also present in the other
	def unjoin(other)		
		# Ensure the other CSV has the keys present
		if not has_keys?(other)
			raise "ERROR: Could not find all key columns #{@keys.to_s} in other CSV"
		end
		
		# Because .length will change as we delete, we must save ahead of time
		# and also track the number of rows we've removed
		length = @matrix.length
		removed_count = 0
		
		# Iterate our matrix removing rows present in the other CSV
		0.upto length do |index|
			# nil row check
			if not @matrix[index-removed_count]
				next
			end
			
			# If this row IS also present in other, delete it here
			if also_present?(@matrix[index-removed_count], other)
				@matrix.delete(index-removed_count)
				removed_count += 1
			end
		end		
	end
	
	def bring(other, cols)
		# Ensure the other CSV has the keys present
		if not has_keys?(other)
			raise "ERROR: Could not find all key columns #{@keys.to_s} in other CSV"
		end
		
		cols.each do |col|
			# Make sure it exists in the other CSV
			if not other.headers.index(col)
				raise "ERROR: Could not find column #{col} to bring()"
			end
			
			# Make sure its not already in this CSV
			if @headers.index(col)
				raise "ERROR: Could not bring column #{col}- it already exists in destination"
			end
			
			# Add the column header
			@headers<< col
		end
		
		# Iterate each of our rows, find a match, & add the columns we're bringing
		@matrix.each do |row|				
			match_row = also_present?(row, other)
			
			if match_row
				# Bring each column along for the ride
				cols.each do |col|
					row<< match_row[col]
				end
			end
		end
	end
	
	private
	#######
	include CSValidation 
end

class ComboCSV < SuiteCSV
	attr_reader :keys

	def initialize(filename, keys)
		@keys = keys
		super(filename)
		key_check
	end

	def combine(other)
		# Ensure the other CSV has the keys present
		if not has_keys?(other)
			raise "ERROR: Could not find all key columns #{@keys.to_s} in other CSV"
		end

		# Initialize the array where we'll keep track of columns added
		new_cols = Array.new

		# Iterate each column in the other CSV
		other.headers.each do |col|
			# If this column is a key, its safe
			if @keys.index(col)
				next
			end

			# If this column is NOT a key, but IS present, it
			# poses a conflict for the combine process
			if @headers.index(col)
				raise "ERROR: Cannot combine due to conflicting, non-key column: #{col}"
			end

			# Add the column header
			@headers<< col
			new_cols<< col
		end

		# Iterate each of our rows & if we find a match, bring the columns from the other
		@matrix.each do |row|
			match_row = also_present?(row, other)

			if match_row
				# Bring each column along
				new_cols.each do |new_col|
					row<< match_row[new_col]
				end
			end
		end

		# Iterate all the rows in the other CSV, and add them
		# in if they're not yet present here
		other.each do |other_row|
			if not already_present?(other_row)
				push_row other_row
			end
		end

	end

	private
	#######
	include CSValidation
end