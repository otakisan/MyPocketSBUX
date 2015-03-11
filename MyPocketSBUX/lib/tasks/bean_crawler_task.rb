require "#{Rails.root}/app/models/bean"
require 'open-uri'
require 'nokogiri'
require 'json'

ROOT_URL = "http://www.starbucks.co.jp"
 
class Tasks::BeanCrawlerTask
  def self.execute
    Rails.logger.debug("BeanCrawlerTask start...")
    #crawlstorebystoreurl("http://www.starbucks.co.jp/store/search/detail.php?id=888")
    crawlbean
    Rails.logger.debug("BeanCrawlerTask end...")
  end

  def self.beandetail(url)
    
    #p url
    bean_doc = Nokogiri::HTML(open(url))
    #p bean_doc.title 
  
    bean_detail = bean_doc.xpath('//article[contains(@class, "productDetail")]')
    bean_name = bean_detail.css('h2').inner_text
    bean_price = bean_detail.xpath('//p[@class="productInfoDetail"]//span[@class="price"]').inner_text
    bean_price = bean_price.delete(",¥").to_i.to_s
    if bean_price.to_i == 0 then
      bean_price = bean_detail.xpath('//div[@class="productInfo"]//ul[@class="selectList"]/li[1]//span[@class="price"][1]').inner_text
      bean_price.delete!(",¥")
    end
  
    product_special = bean_detail.xpath('//div[@class="productInfo"]//p[@class="specialItem"]/span').inner_text
  
    # 通知
    notification = bean_detail.css('div.productInfo > p.notification').inner_text
  
    if !bean_name.include?("セット") then
      # 名称
      p bean_name
      # 価格
      p bean_price
      # カテゴリ
      p category = /\/(\w+)(?:(?=\/\d+\/))/.match(url).to_a[1]
      # JANコード
      p jan_code= /\/(\d+)\//.match(url).to_a[1]
      # 限定
      p product_special
      # 告知
      p notification
  
      # 詳細
      #p bean_detail.css('table.specification.coffeeDetail tr td.item').xpath('.[text()="生産地"]').inner_text
      # 生産地
      p growing_region = bean_detail.xpath('//table[@class="specification coffeeDetail"]//tr/td[@class="item" and text()="生産地"]/following-sibling::node()[@class="detail"]').inner_text
      # 加工方法
      p processing_method = bean_detail.xpath('//table[@class="specification coffeeDetail"]//tr/td[@class="item" and text()="加工方法"]/following-sibling::node()[@class="detail"]').inner_text
      # 風味のキーワード
      p flavor = bean_detail.xpath('//table[@class="specification coffeeDetail"]//tr/td[@class="item" and text()="キーワード"]/following-sibling::node()[@class="detail"]').inner_text.gsub("\r\n", "\t")
      bodyandacidity =  bean_detail.xpath('//table[@class="specification coffeeDetail"]//tr/td[@class="item" and text()="風味"]/following-sibling::node()[@class="detail"]').inner_text.gsub("\r\n", "\t").split("\t")
      # 酸味
      acidity = bodyandacidity[0].split("：")
      p acidity[0] + ":" + acidity[1]  
      # コク
      body = bodyandacidity[1].split("：")
      p body[0] + ":" + body[1]  
      # 相性のよいフレーバー
      p complementary_flavors = bean_detail.xpath('//table[@class="specification coffeeDetail"]//tr/td[@class="item" and text()="相性のよいフレーバー"]/following-sibling::node()[@class="detail"]').inner_text.gsub("\r\n", "\t")
      # 注釈
      notes = ""

      # 登録
      bean_model = Bean.new
      bean_model.attributes = { name: bean_name, category: category, jan_code: jan_code, price: bean_price, special: product_special, notes: notes, notification: notification, growing_region: growing_region, processing_method: processing_method, flavor: flavor, body: body[1], acidity: acidity[1], complementary_flavors: complementary_flavors }
      p bean_model.save

    end
  
  end
  
  def self.crawlbean
    doc = Nokogiri::HTML(open("http://www.starbucks.co.jp/beans/"))
  
    p doc.title
    #doc.xpath('//article[contains(@class,"productList")]').each do |node|
    doc.css('body > div.mainContents.notExNav > article > ul.row.listGrid.js-component > li.col.seasonal,li.col.reserve,li.col.blonde,li.col.medium,li.col.dark').each do |node|
      #p node.inner_text
      sleep(4)
      beandetail(ROOT_URL + node.css('a').first.attribute("href").value)
  
    end
  end


 
end
