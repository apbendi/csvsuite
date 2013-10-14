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
      base_file = MergeCSV.new base_file, merge_columns
      merge_in_file = SuiteCSV.new merge_in_file
      base_file.merge merge_in_file

      new_file_name = "Mergify-#{File.basename(base_file)}-#{File.basename(merge_in_file)}.csv"
      base_file.write(new_file_name)
      return new_file_name
    end

    private

    def self.print_mergify_usage
      puts "Usage: mergify base_file merge_in_file \"column_key_1,column_key_2\""
      return false
    end

  end
end
