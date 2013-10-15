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
      return print_excelify_usage
    end

    def self.excelify(args)

    end

    private

    def self.print_mergify_usage
      puts "Usage: mergify base_file merge_in_file \"column_key_1,column_key_2\""
      return false
    end

    def self.print_excelify_usage
      puts "Usage: excelify file_name column"
      return false
    end

  end
end
