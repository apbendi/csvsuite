#!/opt/local/bin/ruby1.9

$LOAD_PATH << "../lib"
$LOAD_PATH << "../../normalize-us-street-address"
require 'suitecsv.rb'
require 'street_address'

# Verify file passed for argument
if not file_name = ARGV[0]
	puts "No file to run; usage: excelify.rb file_name"
	Process.exit
end

# Verify the script to run exists locally
if not File.exists? file_name
	puts "File not found: #{file_name}"
	Process.exit
end

# Open the CSV for 
addy_csv = SuiteCSV.new file_name

# Validate all expectected columns are present
mandatory_cols = ["zip"]

mandatory_cols.each do |mand_col|
	# If we don't find one of the required columns, shut it down
	if not addy_csv.headers.index mand_col
		puts "Can not find mandatory column: #{mand_col}"
		puts "CSV must include: #{mandatory_cols}"
		Process.exit
	end
end

addy_csv.excelify "zip"
addy_csv.write "excely_out.csv"