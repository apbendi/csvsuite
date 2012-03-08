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
	end
	
	def write(filename)
		
		out_file = File.new filename, "w"
		out_file.puts @headers.to_csv
		
		@matrix.each do |row|
			# ignore nil row
			if row
				# Swap out open close tags to prevent escaping
				# TODO: could be made more efficient by using an instance var to track if anything
				# has actually been excelified
				out_file.puts row.to_csv.gsub("|EXCEL_OPEN|", "=\"").gsub("|EXCEL_CLOSE|", " \"")
			end
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
				raise "ERROR: headers do not match, could not find: #{header}"
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
			
			# Add this row to our table
			if not already_present
				$stdout.puts "Adding row: #{other_row}"
				push_row other_row
			else
				$stdout.puts "Ignoring match: #{other_row}"
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

class JoinCSV < SuiteCSV
	
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
	
	# Take two CSVs and produce a result that is the overlap of
	# the two w/o repeats
	def join(other)
		
		# Ensure the other CSV has the keys present
		@keys.each do |key|
			if not other.headers.index(key)
				raise "ERROR: Could not find key column #{key} in other CSV"
			end
		end
		
		indices = []
		
		
		length = @matrix.length
		removed_count = 0
		# Iterate our matrix removing rows not present in the other CSV
		0.upto length do |index|
			if not @matrix[index-removed_count]
				next
			end
			if not also_present?(@matrix[index-removed_count], other)
				indices<< index
				@matrix.delete(index-removed_count)
				removed_count += 1
				#$stdout.puts index.to_s + ": " + @matrix[index].to_s
				#if not @matrix[index].to_s.length > 2
				#	raise "Huh? " + index.to_s
				#end
				#$stdout.puts "Delete: " + index.to_s + "- " + @matrix[index]["split_zip"]
			else
				$stdout.puts index.to_s + ": " + @matrix[index-removed_count].to_s
				#$stdout.puts "Match: " + index.to_s + "- " + @matrix[index]["split_zip"]
			end
		end
		
		#(indices.length-1).downto 0 do |
		
		#old_matrix = @matrix
		#@matrix = CSV::Table.new @headers
		
		#old_matrix.each do |row|
		#	if also_present?(row, other)
		#		@matrix<< row
		#		$stdout.puts "Keep: " + row["split_zip"]
		#	else
		#		$stdout.puts "Delete: " + row["split_zip"]
		#	end
		#end
		
		#@matrix.each do |row|
		#	if also_present?(row, other)
		#		$stdout.puts "Keep: " + row["split_zip"]
		#	else
		#		$stdout.puts "Delete: " + row["split_zip"]
		#		@matrix.delete @matrix.index(row)
		#	end
		#end
		
		
	end
	
	def unjoin(other)
		
		# Ensure the other CSV has the keys present
		@keys.each do |key|
			if not other.headers.index(key)
				raise "ERROR: Could not find key column #{key} in other CSV"
			end
		end
		
		indices = []
		
		
		length = @matrix.length
		removed_count = 0
		# Iterate our matrix removing rows not present in the other CSV
		0.upto length do |index|
			if not @matrix[index-removed_count]
				next
			end
			if not also_present?(@matrix[index-removed_count], other)
				indices<< index
				#$stdout.puts index.to_s + ": " + @matrix[index].to_s
				#if not @matrix[index].to_s.length > 2
				#	raise "Huh? " + index.to_s
				#end
				#$stdout.puts "Delete: " + index.to_s + "- " + @matrix[index]["split_zip"]
			else
				$stdout.puts index.to_s + ": " + @matrix[index-removed_count].to_s
				#$stdout.puts "Match: " + index.to_s + "- " + @matrix[index]["split_zip"]
				@matrix.delete(index-removed_count)
				removed_count += 1
			end
		end
		
		#(indices.length-1).downto 0 do |
		
		#old_matrix = @matrix
		#@matrix = CSV::Table.new @headers
		
		#old_matrix.each do |row|
		#	if also_present?(row, other)
		#		@matrix<< row
		#		$stdout.puts "Keep: " + row["split_zip"]
		#	else
		#		$stdout.puts "Delete: " + row["split_zip"]
		#	end
		#end
		
		#@matrix.each do |row|
		#	if also_present?(row, other)
		#		$stdout.puts "Keep: " + row["split_zip"]
		#	else
		#		$stdout.puts "Delete: " + row["split_zip"]
		#		@matrix.delete @matrix.index(row)
		#	end
		#end
		
		
	end
	
	private
	
	# Is this row present in the other CSV?
	def also_present?(row, other)
	
		other.matrix.each do |other_row|
			if keys_match?(row, other_row)
				return true
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
			if not my_row[key] =~ /^#{other_row[key]}$/i
				return false
			end
		end
		
		#$stdout.puts "Match: " + my_row["split_zip"] + " AND " + other_row["split_zip"]
		
		# If we checked values at each key w/o mismatch, its the same
		return true
	end

end


#contra = SuiteCSV.new "../contra-pamphlet-full.csv"
#contra.split_zip "zip", "split_zip"
#contra.write "contra-pampphlet-full-splitzip.csv"

contra_zip = JoinCSV.new "contra-pampphlet-full-splitzip.csv", ["split_zip"]
philly_zips = SuiteCSV.new "../Philly_Zips.csv"
#contra_zip.join philly_zips
#contra_zip.write "contra-pamphlet-removed-philly.csv"
contra_zip.unjoin philly_zips
contra_zip.write "contra-pamphlet-with-philly-removed.csv"

#sample1 = JoinCSV.new "sample1.csv", ["internal id", "last name"]
#sample2 = SuiteCSV.new "sample2.csv"
#sample1.join sample2
#sample1.write "results_join.csv"

#rented_dres = SuiteCSV.new "../rented_us_DREs.csv"
#rented_dres.split_zip "zip", "split_zip"
#rented_dres.write "../rented_us_DREs_splitzip.csv"

#net_dres = SuiteCSV.new "../netsuite_us_DREs.csv"
#net_dres.split_zip "zip", "split_zip"
#net_dres.write "../netsuite_us_DREs_splitzip.csv"

#rented = MergeCSV.new("../rented_us_DREs_splitzip.csv", ["l_name", "split_zip"])
#netsuite = SuiteCSV.new("../netsuite_us_DREs_splitzip.csv")
#rented.merge netsuite
#rented.write "merged_us_DREs.csv"

#merged = SuiteCSV.new("merged_us_DREs.csv")
#merged.excelify "zip"
#merged.write "merged_us_DREs_excelified.csv"

#sample1 = SuiteCSV.new "sample1.csv"
#sample1.split_zip "zip", "split_zip"
#sample1.write "split_results.csv"

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
