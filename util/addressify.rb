#!/opt/local/bin/ruby1.9

$LOAD_PATH << "../lib"
$LOAD_PATH << "../../normalize-us-street-address"
require 'suitecsv.rb'
require 'street_address'

# Verify file passed for argument
if not file_name = ARGV[0]
	puts "No file to run: addressify.rb file_name"
	Process.exit
end

# Verify the script to run exists locally
if not File.exists? file_name
	puts "File not found #{file_name}"
	Process.exit
end