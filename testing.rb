require_relative 'suitecsv.rb'

contra_zip = JoinCSV.new "contra-pampphlet-full-splitzip.csv", ["split_zip"]
philly_zips = SuiteCSV.new "../Philly_Zips.csv"
contra_zip.unjoin philly_zips
contra_zip.matrix.delete "split_zip"
contra_zip.write "contra-pamphlet-with-philly-removed-2.csv"