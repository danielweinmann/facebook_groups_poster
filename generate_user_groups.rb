require 'dotenv'
Dotenv.load

require 'koala'
require 'csv'

@minimum_members = ENV["MINIMUM_MEMBERS"].to_i
begin
  @groups_to_exclude = CSV.read('groups_to_exclude.csv').map { |line| line[0] }
rescue
  @groups_to_exclude = []
end
@graph = Koala::Facebook::API.new(ENV["FACEBOOK_ACCESS_TOKEN"])

@graph.get_connections("me", "groups").each do |group|
  puts "#{group["id"]}, #{group["name"]}"
  next if group["administrator"]
  next if group["name"].match(/couchsurfing/i)
  next if @groups_to_exclude.include?(group["id"])
  members = @graph.get_connections(group["id"], "members")
  count = members.size
  while count < @minimum_members do
    members = members.next_page
    break if members.nil? || members.empty?
    count += members.size
  end
  next if count < @minimum_members
  CSV.open("user_groups.csv", "a") do |csv|
    csv << [group["id"], group["name"]]
  end
end
