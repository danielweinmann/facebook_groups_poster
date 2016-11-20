require 'wombat'

class FacebookGroupCrawler
  include Wombat::Crawler
  attr_accessor :group_id

  def initialize(group_id)
    self.group_id = group_id
    super()
  end

  base_url "http://www.facebook.com"
  path "/groups/#{self.group_id}"
end
