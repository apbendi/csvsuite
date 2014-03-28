module CSVSuite
  module Utils
    
    def self.cmd_mergify(args)
      # Validate arguments
      if not base_file = args[0]
        puts "No base file provided"
        return self.print_mergify_usage
      elsif not merge_in_file = args[1]
        puts "No file to merge in provided"
        return self.print_mergify_usage
      elsif not key_column_string = args[2]
        puts "No key columns to merge on provided"
        return self.print_mergify_usage
      else
        merge_keys = key_column_string.split(",")
        return self.mergify(base_file, merge_in_file, merge_keys)
      end
    end

    def self.mergify(base_file, merge_in_file, merge_columns)
      base = MergeCSV.new base_file, merge_columns
      merge_in = SuiteCSV.new merge_in_file
      base.merge merge_in

      new_file_name = "Mergify-#{File.basename(base_file, ".*")}-#{File.basename(merge_in_file, ".*")}.csv"
      base.write(new_file_name)
      return new_file_name
    end

    def self.cmd_excelify(args)
      if not file_name = args[0]
        puts "No file provided"
        return self.print_excelify_usage
      elsif not column_name = args[1]
        puts "No column name provided"
        return self.print_excelify_usage
      else
        return self.excelify(file_name, column_name)
      end
    end

    def self.excelify(file_name, column_name)
      csvfile = SuiteCSV.new file_name
      csvfile.excelify(column_name)

      new_file_name = "Excelify-#{File.basename(file_name, ".*")}.csv"
      csvfile.write(new_file_name)
      return new_file_name
    end

    def self.cmd_addressify(args)
      # Verify file passed for argument
      if not file_name = ARGV[0]
        puts "No file to run"
        return self.print_addressify_usage
      end

      # Verify the script to run exists locally
      if not File.exists? file_name
        puts "File not found: #{file_name}"
        return self.print_addressify_usage
      end

      # Open the CSV for 
      addy_csv = SuiteCSV.new file_name

      # Validate all expectected columns are present
      mandatory_cols = ["addr", "addr2", "city", "state", "zip"]

      mandatory_cols.each do |mand_col|
        # If we don't find one of the required columns, shut it down
        if not addy_csv.headers.index mand_col
          puts "Could not find mandatory column: #{mand_col}"
          puts "CSV must include: #{mandatory_cols}"
          return self.print_addressify_usage
        end
      end

      self.addressify(addy_csv, file_name)
    end

    def self.addressify(addy_csv, file_name)
      # This sucks, and obviously makes this useless as a general gem outside of my computer
      # but we have to live with it for now, as I've added hacks to this Gem to support
      # PO Boxes, etc... One day, we can clean this up, right??
      $LOAD_PATH << "/Users/ben/scripts/normalize-us-street-address"
      require 'street_address'

      # Add new columns
      addy_csv.headers<< "split_zip"
      addy_csv.headers<< "addr_num"

      non_norm_count = 0

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
          city_name = city_name.gsub(/St\.?/i, "Saint")
        end

        orig_addy = row["addr"].to_s + " " + row["addr2"].to_s + ", " + city_name.to_s + ", " + row["state"].to_s + " " + row["zip"].to_s
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
          non_norm_count = non_norm_count + 1
        end
      end

      #addy_csv.excelify "zip"
      puts "#{non_norm_count} addresses could not be normalized"

      addy_csv.write file_name.split(".csv")[0] + "-addressify.csv"
    end

    private

    def self.print_mergify_usage
      puts "Usage: mergify base_file merge_in_file \"column_key_1,column_key_2\""
      return false
    end

    def self.print_excelify_usage
      puts "Usage: excelify file_name column_name"
      return false
    end

    def self.print_addressify_usage
      puts "Usage: addressify"
      return false
    end

  end
end
