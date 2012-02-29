require 'csv'

class SuiteCSV < CSV
	
	attr_reader :matrix
	
	# Only accept filenames, not strings, when defining a CSV
	# Always require headers to be true
	# Read the file & load it into a matrix
	def initialize(filename)
		@filename = filename
		super File.new(@filename), {:headers => true}
		@matrix = self.read
	end
	
end

# Take two CSVs and produce a result that is the combination
# of the two w/o repeats
class MergeCSV < SuiteCSV

	attr_reader :keys
	
	def initialize(filename, keys)
		@keys = keys
		super(filename)
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

sample1 = SuiteCSV.new("sample1.csv")

puts sample1.headers

sample1.matrix.each do |row|
	puts row
end
