require "#{Rails.root}/app/models/food"
require 'open-uri'
require 'nokogiri'
require 'json'

ROOT_URL = "http://www.starbucks.co.jp"
 
class Tasks::FoodCrawlerTask
  def self.execute
    Rails.logger.debug("FoodCrawlerTask start...")
    #crawlstorebystoreurl("http://www.starbucks.co.jp/store/search/detail.php?id=888")
    crawlfood
    Rails.logger.debug("FoodCrawlerTask end...")
  end

  def self.product(node)
    
    product_url = node.css('a').attribute('href').value
    product_doc = Nokogiri::HTML(open(ROOT_URL + product_url))
    #p product_doc.title 
  
    product_detail = product_doc.xpath('//article[contains(@class, "productDetail")]')
    product_name = product_detail.css('h2').inner_text
    product_price = product_detail.xpath('//p[@class="productInfoDetail"]//span[@class="price"]').inner_text

    # 名称
    p product_name

    # 価格
    p product_price.delete!('¥')

    # 限定  
    product_special = product_detail.xpath('//div[@class="productInfo"]//p[@class="specialItem"]/span').inner_text
    p product_special
  
    # カテゴリ
    p category = /\/(\w+)(?:(?=\/\d+\/))/.match(product_url).to_a[1]
  
    # JANコード
    p jan_code = /\/(\d+)\//.match(product_url).to_a[1]
  
    # 通知（存在するものとそうでないものとある）
    notification =  product_detail.css('div.productInfo > p.notification').inner_text
    if notification.empty? then
      notification = product_detail.css('div.productInfo > p.fontS').inner_text
    end
    p notification

    # 注釈（ひとまず固定で空）
    notes = ""

    # 登録
    food_model = Food.new
    food_model.attributes = { name: product_name, category: category, jan_code: jan_code, price: product_price.to_i, special: product_special, notes: notes, notification: notification }
    p food_model.save
  end

  def self.crawlfood  
    doc = Nokogiri::HTML(open("http://www.starbucks.co.jp/food/"))
    
    p doc.title
    doc.xpath('//article[contains(@class,"productList")]').each do |node|
    
      p "オススメ"
      node.xpath('//li[@class="col recommend"]').each do |recommended|
        sleep(4)
        product(recommended)
      end
    
      p "レギュラー"
      node.xpath('//li[@class="col "]').each do |regular|
        sleep(4)
        product(regular)
      end
    
    end
  end

 
end
