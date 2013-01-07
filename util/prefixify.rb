#!/opt/local/bin/ruby1.9

$LOAD_PATH << "../lib"
require 'suitecsv.rb'

# Verify file passed for argument
if not file_name = ARGV[0]
	puts "No file to run; usage: prefixify.rb file_name"
	Process.exit
end

# Verify the script to run exists locally
if not File.exists? file_name
	puts "File not found: #{file_name}"
	Process.exit
end

# Open the CSV for 
orig_list = SuiteCSV.new file_name

# Validate all expectected columns are present
mandatory_cols = ["prefix"]

mandatory_cols.each do |mand_col|
	# If we don't find one of the required columns, shut it down
	if not orig_list.headers.index mand_col
		puts "Can not find mandatory column: #{mand_col}"
		puts "CSV must include: #{mandatory_cols}"
		Process.exit
	end
end

fr_rev = "Rev"

orig_list.each do |row|
	if not row["prefix"]
		next
	end

	# "Non Breaking Space" - wow, seriously?
	prefix = row['prefix'].gsub(/\u00a0/u, " ")

	if prefix.match(/^(#{fr_rev}|Dr|Sr|Dcn|Msgr|Rev Msgr)$/)
		row["new_prefix"] = prefix
	elsif prefix.match(/^Father\s*$/i) or prefix.match(/^fr\.?\s*$/i)
		row["new_prefix"] = fr_rev
	elsif prefix.match(/^Rev(e|a)r(e|a)nd\s*$/i) or prefix.match(/^rev\.?\s*$/i)
		row["new_prefix"] = fr_rev
	elsif prefix.match(/^Very Rev(e|a)r(e|a)nd\s*$/i) or prefix.match(/^very rev\.?\s*$/i)
		if fr_rev == "Rev."
			row["new_prefix"] = "Very Rev"
		else
			row["new_prefix"] = fr_rev
		end
	elsif prefix.match(/^Doctor\s*$/i) or prefix.match(/^dr\.?\s*$/i)
		row["new_prefix"] = "Dr"
	elsif prefix.match(/^Sister\s*$/i) or prefix.match(/^sr\.?\s*$/i)
		row["new_prefix"] = "Sr"
	elsif prefix.match(/^Deacon\s*$/i) or prefix.match(/^dcn\.?\s*$/i)
		row["new_prefix"] = "Dcn"
	elsif prefix.match(/^Monsignor\s*$/i) or prefix.match(/^msg?r\.?\s*$/i)
		row["new_prefix"] = "Msgr"
	elsif prefix.match(/^Rev\.?((e|a)r(e|a)nd) Monsignor\s*$/i) or prefix.match(/^rev\.? msg?r\.?\s*$/i)
		row["new_prefix"] = "Rev Msgr"	
	elsif prefix.match(/^Brother\s*$/i) or prefix.match(/^bro?\.?\s*$/i)
		row["new_prefix"] = "Br"
	elsif prefix.match(/^(Mr\.?|Mrs\.?|Ms\.?|Miss)\s*$/i)
		row["new_prefix"] = ""
	else
		row["new_prefix"] = "CHECK-ME"
	end
end

orig_list.write "prefixy_out.csv"