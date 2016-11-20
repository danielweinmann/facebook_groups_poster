require 'dotenv'
Dotenv.load

require File.expand_path('../', __FILE__) + "/facebook_group_crawler.rb"
require 'csv'

@minimum_members = ENV['MINIMUM_MEMBERS'].to_i
begin
  @groups_to_exclude = CSV.read('groups_to_exclude.csv').map { |line| line[0] }
rescue
  @groups_to_exclude = []
end
begin
  @groups_to_join = CSV.read('groups_to_join.csv').map { |line| line[0] }
rescue
  @groups_to_join = []
end
begin
  last_group_id = File.read(File.expand_path('../', __FILE__) + "/join.tmp")
rescue
  last_group_id = ""
end
index = @groups_to_join.find_index(last_group_id)
@groups_to_join = @groups_to_join[index + 1..(@groups_to_join.size - 1)] if index

@groups_to_join.each do |group_id|
  next if @groups_to_exclude.include?(group_id)
  puts "Joining '#{group_id}'"
  @crawler = FacebookGroupCrawler.new(group_id)
  @crawler.crawl
  # TODO remove break
  break
  File.open(File.expand_path('../', __FILE__) + "/join.tmp", 'w') { |file| file.write(group_id) }
end
