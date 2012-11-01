#!/opt/local/bin/ruby1.9

$LOAD_PATH << "../lib"
$LOAD_PATH << "../../normalize-us-street-address"
require 'suitecsv.rb'
require 'street_address'

# Verify file passed for argument
if not file_name = ARGV[0]
	puts "No file to run; usage: addressify.rb file_name"
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
mandatory_cols = ["addr", "addr2", "city", "state", "zip"]

mandatory_cols.each do |mand_col|
	# If we don't find one of the required columns, shut it down
	if not addy_csv.headers.index mand_col
		puts "Can not find mandatory column: #{mand_col}"
		puts "CSV must include: #{mandatory_cols}"
		Process.exit
	end
end

# Add new columns
addy_csv.headers<< "split_zip"
addy_csv.headers<< "addr_num"

# Iterate each row of the CSV & perform the normalization
addy_csv.each do |row|	

	city_dir, city_name = nil

	# Pre-Process Cities w/ Directional Names, because we know our addy normalizer can't handle it
	if row["city"] and row["city"].match(/(south|north|east|west)\s+/i)

		# Isolate the directional word & the rest of the city's name
		split_city = row["city"].scan(/(south|north|east|west)\s+(.*)/i)
		city_dir = split_city[0][0]
		city_name = split_city[0][1]

	# If there is no directional word, simply use the city's name
	elsif row["city"]
		city_name = row["city"]
	end

	# Also pre-process Cities w/ St. Names, another case not handled correctly
	if ( city_name and \
		( city_name.match(/^St\.?\s+/i) or city_name.match(/^.*\s+St\.?\s+/i) ) )
		#puts row.to_s
		city_name = city_name.gsub(/St\.?/i, "Saint")
	end

	orig_addy = row["addr"].to_s + " " + row["addr2"].to_s + " " + city_name.to_s + ", " + row["state"].to_s + " " + row["zip"].to_s
	norm_addy = StreetAddress.parse(orig_addy)

	if norm_addy
		# Build the street address section of the normalized address & add row
		row["addr"] = "#{norm_addy.number} #{norm_addy.prefix} #{norm_addy.street} #{norm_addy.type} #{norm_addy.suffix}" \
						.gsub(/\s{2,}/, " ").gsub(/\s$/, '')

		# Put the direction of the city back if we previously took it out & add row
		if city_dir
			row["city"] = "#{city_dir} #{norm_addy.city}"
		else
			row["city"] = norm_addy.city
		end
		# Swap "Saint" in the city name for the abbreviation, "St"
		if ( row["city"].match(/^Saint\s+/i) or row["city"].match(/^.*\s+Saint\s+/i) )
			row["city"] = row["city"].gsub(/Saint/i, "St")
		end

		# Add rows for normalized State & Zip
		row["state"] = norm_addy.state
		row["split_zip"] = norm_addy.zip

		# Add row for just the norm addy number
		row["addr_num"] = norm_addy.number
	else
		row["addr"] = ""
		row["city"] = ""
		row["state"] = ""
		row["zip"] = ""
		row["split_zip"] = ""
	end
end

addy_csv.excelify "zip"

addy_csv.write "addy_out.csv"