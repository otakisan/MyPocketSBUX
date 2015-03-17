require "#{Rails.root}/app/models/bean"
require "#{Rails.root}/app/models/food"
require 'open-uri'
require 'nokogiri'
require 'json'

ROOT_URL = "http://www.starbucks.co.jp"
 
class Tasks::PairingCrawlerTask
  def self.execute
    Rails.logger.debug("PairingCrawlerTask start...")
    #crawlstorebystoreurl("http://www.starbucks.co.jp/store/search/detail.php?id=888")
    crawlpairing
    Rails.logger.debug("PairingCrawlerTask end...")
  end

  def self.crawlpairing
  
    doc = Nokogiri::HTML(open("http://www.starbucks.co.jp/pairing/coffee.html"))
  
    p doc.title
    pair_list = doc.xpath('//article//div[contains(@class,"withCarouselCol")]')
    pair_list.each do |pair|
  
      bean_code = /\/(\d+)\//.match(pair.xpath('p[@class="imgL"]//a[@href]').first.attribute("href").value).to_a[1]
      bean_name = pair.xpath('p[@class="imgL"]//a[@href]/span[contains(@class, "txtLink")]').inner_text
      beans = Bean.where("jan_code = ?", bean_code)
      bean_model = nil
      if beans.size > 0 then
        bean_model = beans.first
        p "found:" + bean_model.jan_code + ":" + bean_model.name
      else
        p "not found:" + bean_code + ":" + bean_name
      end
  
      food_list = pair.xpath('div[@class="colR"]//li[contains(@class, "carouselItem")]')
      food_list.each do |food|
        food_code = /\/(\d+)\//.match(food.xpath('a[@href]').first.attribute("href").value).to_a[1]
        food_name = food.xpath('a[@href]/span').inner_text
        foods = Food.where("jan_code = ?", food_code)
        food_model = nil
        if foods.size > 0 then
          food_model = foods.first
          p "found:" + food_model.jan_code + ": " + food_model.name
          if bean_model != nil && food_model != nil then
           # 登録
           pairing_model = Pairing.new
           pairing_model.attributes = { bean: bean_model, food: food_model }
           p pairing_model.save 
          end
        else
          p "not found:" + food_code + ":" + food_name
        end
      end
 
 
    end
  
  end

end
