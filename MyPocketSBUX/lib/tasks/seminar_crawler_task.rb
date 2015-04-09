require "#{Rails.root}/app/models/seminar"
require "#{Rails.root}/app/models/store"
require 'open-uri'
require 'nokogiri'
require 'json'

ROOT_URL = "http://www.starbucks.co.jp"
 
class Tasks::SeminarCrawlerTask
  def self.execute
    Rails.logger.debug("SeminarCrawlerTask start...")
    #crawlstorebystoreurl("http://www.starbucks.co.jp/store/search/detail.php?id=888")
    crawlseminar
    Rails.logger.debug("SeminarCrawlerTask end...")
  end

  def self.seminardetail(url)
    
    p url
    seminar_doc = Nokogiri::HTML(open(url))
    #p seminar_doc.title 
  
    seminar_detail = seminar_doc.xpath('//article[contains(@class, "seminar")]')
    p edition = seminar_detail.css('h2').inner_text
  
    p seminar_doc.css('body > div.mainContents.notExNav > article > div.row.js-component > div.col2.seminars > div > div > ul > li.viewShops').length
    seminar_doc.css('body > div.mainContents.notExNav > article > div.row.js-component > div.col2.seminars > div > div > ul.seminarList > li.viewShops').each do |store|
      p "-------------------"
      # ID
      p store_id = /id=(\d+)/.match(store.css('div.storeInfo > p.storeName > a').first.attribute("href").value).to_a[1].to_i
      p store_name = store.css('div.storeInfo > p.storeName > a').xpath('text()').to_s
      # 開催日時
      p seminar_datetime = store.css('div.seminarInfo > table.details tr:nth-child(1) > td.detail').inner_text
      #p seminar_datetime = store.css('div.seminarInfo > table > tbody > tr:nth-child(1) > td.detail').inner_text
      #p datearray = /(\d{2})\/(\d{2})\((.)\)\s*(\d{2}):(\d{2}).(\d{2}):(\d{2})/.match(seminar_datetime).to_a
      #p datearray = /(\d{2})\/(\d{2})\((.)\).*?(\d{1,2}):(\d{2})(?:.(\d{1,2}):(\d{2}))?/.match(seminar_datetime).to_a
      p datearray = /(\d{2})\/(\d{2})\((.)\)[[:blank:]]*?(\d{1,2}):(\d{2})(?:.(\d{1,2}):(\d{2}))?/.match(seminar_datetime).to_a
      p seminar_date = Time.new(Time.now.month > datearray[1].to_i ? Time.now.year + 1 : Time.now.year, datearray[1].to_i, datearray[2].to_i)
      p start_time = Time.new(seminar_date.year, seminar_date.month, seminar_date.day, datearray[4].to_i, datearray[5].to_i)
      p end_time = Time.new(seminar_date.year, seminar_date.month, seminar_date.day, datearray[6].to_i, datearray[7].to_i)
      p day_of_week = datearray[3]
  
      # 定員
      p capacity = store.css('div.seminarInfo > table tr:nth-child(2) > td.detail').inner_text.to_i
  
      # 締切日
      p deadlinearray = /(\d{2})\/(\d{2})\((.)\)/.match(store.css('div.seminarInfo > table tr:nth-child(3) > td.detail').inner_text).to_a
      p deadline = Time.new(Time.now.month > deadlinearray[1].to_i ? Time.now.year + 1 : Time.now.year, deadlinearray[1].to_i, deadlinearray[2].to_i)
      p status = store.css('input.seminarStatus').first.attribute("value").value

      # Store
      store_model = nil
      store_table_id = 0
      store_models = Store.where("store_id = ?", store_id)
      if store_models.count > 0 then
        p "ヒット：" + store_models.count.to_s
        arr = store_models.pluck(:name)
        p arr
        store_model = store_models.first
        store_table_id = store_model.id
        p "store table id:" + store_table_id.to_s
      end

      # 登録
      seminar_model = Seminar.new
      p seminar_model.attributes = { store: store_model, edition: edition, start_time: start_time, end_time: end_time, day_of_week: day_of_week, capacity: capacity, deadline: deadline, status: status }
      p seminar_model.save

    end
  
  end
  
  def self.crawlseminar
=begin
    doc = Nokogiri::HTML(open("http://www.starbucks.co.jp/seminar/index.html"))
  
    p doc.title
    #doc.xpath('//article[contains(@class,"productList")]').each do |node|
    doc.css('body > div.mainContents.notExNav > article > div div.col1.panel.type2').each do |node|
      #p node.inner_text.strip
      seminardetail(ROOT_URL + node.css('a').first.attribute("href").value)
=end
seminardetail("https://www.starbucks.co.jp/seminar/beginner.html")
#seminardetail("https://www.starbucks.co.jp/seminar/chocolate.html")
seminardetail("https://www.starbucks.co.jp/seminar/espresso.html")
seminardetail("https://www.starbucks.co.jp/seminar/hand-drip.html")
seminardetail("https://www.starbucks.co.jp/seminar/pairing.html")
seminardetail("https://www.starbucks.co.jp/seminar/custom-blend.html")
seminardetail("https://www.starbucks.co.jp/seminar/reserve.html")

  end
end
