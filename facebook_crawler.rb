require 'watir'

class FacebookCrawler
  BASE_URL = "https://www.facebook.com"

  attr_accessor :email
  attr_accessor :password
  attr_accessor :browser

  def initialize(email, password)
    self.email = email
    self.password = password
    self.browser = Watir::Browser.new :phantomjs
    login
  end

  def close
    self.browser.close
  end

  def login
    browser.goto(BASE_URL)
    browser.text_field(id: 'email').set(self.email)
    browser.text_field(id: 'pass').set(self.password)
    browser.button(type: 'submit', text: 'Log In').click
  end

  def join_group(id)
    browser.goto("#{BASE_URL}/groups/#{id}")
    link = browser.link(text: 'Participar do grupo')
    return unless link.exists?
    link.click
    true
  end
end
