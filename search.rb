require 'dotenv'
Dotenv.load

require 'koala'
require 'csv'

@minimum_members = ENV['MINIMUM_MEMBERS'].to_i
begin
  @exclude = CSV.read('exclude.csv').map { |line| line[0] }
rescue
  @exclude = []
end
begin
  @searches = CSV.read('searches.csv').map { |line| line[0] }
rescue
  @searches = []
end
last_search = File.read(File.expand_path('../', __FILE__) + "/search.tmp")
index = @searches.find_index(last_search)
@searches = @searches[index + 1..(@searches.size - 1)] if index
@graph = Koala::Facebook::API.new(ENV['FACEBOOK_ACCESS_TOKEN'])

@searches.each do |search|
  puts "Searching for '#{search}'"
  @graph.search(search, type: 'group').each do |group|
    next if group["administrator"]
    next if group["name"].match(/couchsurfing/i)
    next if @exclude.include?(group["id"])
    members = @graph.get_connections(group["id"], "members")
    count = members.size
    while count < @minimum_members do
      members = members.next_page
      break if members.nil? || members.empty?
      count += members.size
    end
    next if count < @minimum_members
    CSV.open(File.expand_path('../', __FILE__) + "/joins.csv", "a") do |csv|
      csv << [group["id"], group["name"]]
    end
    puts "  #{group["id"]}, #{group["name"]}"
  end
  File.open(File.expand_path('../', __FILE__) + "/search.tmp", 'w') { |file| file.write(search) }
end
