$LOAD_PATH << "lib"

require 'suitecsv.rb'

sample1 = SuiteCSV.new "sample1.csv"

#sample1 = MergeCSV.new "sample1.csv", ["internal id", "last name"]
# sample1<< [15, "Jones", "Bob"]
# sample1<< [8, "Jobs", "Steve", "37691"]


# sample2 = SuiteCSV.new "sample2.csv"
# #sample2<< [1, "John", "Smith", "65775"]
# #sample2<< [8, "Steve", "Jobs", "37691"] 
# #sample2<< [15, "Bob", "Jones"]
# #sample2<< [14, "New", "Person"]

# sample1.merge sample2

# sample1.write "sample1_results.csv"

# sample12 = JoinCSV.new "sample1_results.csv", ["internal id", "last name"]
# sample12.join sample2
# sample12.write "sample2_again.csv"

# sample21 = JoinCSV.new "sample1_results.csv", ["internal id", "last name"]
# sample21.unjoin SuiteCSV.new "sample1.csv"
# sample21.write "sample1_again.csv"

#contra = SuiteCSV.new "../contra-pamphlet-full.csv"
#contra.split_zip "zip", "split_zip"
#contra.write "contra-pampphlet-full-splitzip.csv"

#contra_zip = JoinCSV.new "contra-pampphlet-full-splitzip.csv", ["split_zip"]
#philly_zips = SuiteCSV.new "../Philly_Zips.csv"
#contra_zip.join philly_zips
#contra_zip.write "contra-pamphlet-removed-philly-2.csv"
#contra_zip.unjoin philly_zips
#contra_zip.matrix.delete "split_zip"

#contra_zip.write "contra-pamphlet-with-philly-removed-2.csv"

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
