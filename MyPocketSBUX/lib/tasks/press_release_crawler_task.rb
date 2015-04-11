require "#{Rails.root}/app/models/press_release"
require 'open-uri'
require 'nokogiri'
require 'json'

ROOT_URL = "http://www.starbucks.co.jp"
 
class Tasks::PressReleaseCrawlerTask
  def self.execute
    Rails.logger.debug("PressReleaseCrawlerTask start...")
    #crawlstorebystoreurl("http://www.starbucks.co.jp/store/search/detail.php?id=888")
    crawlpressrelease
    Rails.logger.debug("PressReleaseCrawlerTask end...")
  end

  def self.crawlpressreleasebyfiscalyear(fiscalyear)
  
    doc = Nokogiri::HTML(open("http://www.starbucks.co.jp/press_release/pr#{fiscalyear}.php"))
  
    p doc.title
    release_list = doc.xpath('//article//ul[contains(@class,"linkList")]/li')
    #store_links = result_stores.xpath('li[contains(@class, "item")]/a[@href]')
    #p "links:" + store_links.length.to_s
  
    release_list.each do |node|
      release_url = node.xpath('a[@href!=""]')
      if release_url.length > 0 then
        p release_url[0].attribute("href").value
      end
  
      p fisandid = /\/pr(\d+)-(\d+)/.match(release_url.first.attribute("href").value).to_a
      p "fis_y:" + fisandid[1]
      p "pr_id:" + fisandid[2]
      #p "url:" + release_url
      heading = node.xpath('.//p[@class="heading"]').inner_text
      p heading
      date_string = node.xpath('.//p[@class="date"]').inner_text
      p date_string
      p date_parts = /(\d+)\/(\d+)\/(\d+)/.match(date_string)
      p date = Time.new(date_parts[1].to_i, date_parts[2].to_i, date_parts[3].to_i)

      # 登録
      pressrelease_model = PressRelease.new
      pressrelease_model.attributes = { fiscal_year: fisandid[1], press_release_sn: fisandid[2], title: heading, url: release_url[0].attribute("href").value, issue_date: date }
      p pressrelease_model.save

    end
  
  end
  
  def self.crawlpressrelease
  
    for fiscalyear in 2015.step(2000, -1) do
      crawlpressreleasebyfiscalyear(fiscalyear)
      sleep(4)
    end
  
  end
  

end
