require 'dotenv'
Dotenv.load

require File.expand_path('../', __FILE__) + "/facebook_crawler.rb"
require 'csv'

@minimum_members = ENV["MINIMUM_MEMBERS"].to_i
@sleep_seconds = ENV["SLEEP_SECONDS"].to_i
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
@crawler = FacebookCrawler.new(ENV["FACEBOOK_EMAIL"], ENV["FACEBOOK_PASSWORD"])

@groups_to_join.each do |group_id|
  next if @groups_to_exclude.include?(group_id)
  puts "Trying to join #{group_id}..."
  if @crawler.join_group(group_id)
    puts "  ...asked to join!"
  else
    puts "  ...already joined or asked ;)"
  end
  File.open(File.expand_path('../', __FILE__) + "/join.tmp", 'w') { |file| file.write(group_id) }
  puts "  ...waiting #{@sleep_seconds}s"
  sleep @sleep_seconds
end

@crawler.close
