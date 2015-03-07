require "#{Rails.root}/app/models/store"
require 'open-uri'
require 'nokogiri'
require 'json'

 
class Tasks::StoreCrawlerTask
  def self.execute
    Rails.logger.debug("StoreCrawlerTask start...")
    #crawlstorebystoreurl("http://www.starbucks.co.jp/store/search/detail.php?id=888")
    crawlstore
    Rails.logger.debug("StoreCrawlerTask end...")
  end

  def self.crawlstorebystoreurl(store_url, pref_id)
    doc = Nokogiri::HTML(open(store_url))
  
    # 店舗名
    store_name = doc.xpath('//article[contains(@class,"store")]/header/h2').inner_text
    p "StoreName:" + store_name
    #p store_url
  
    # 店舗ID
    store_id = /id=(\d+)/.match(store_url).to_a[1]
    p "Store ID:" + store_id.to_s
  
    store_info = doc.xpath('//table[contains(@class, "storeInfo")]')
  
    # 営業時間
    opening_time_weekday = ""
    closing_time_weekday = ""
    opening_time_saturday = ""
    closing_time_saturday = ""
    opening_time_holiday = ""
    closing_time_holiday = ""
  
    store_time = store_info.xpath('.//td[.="営業時間"]/following-sibling::node()[@class="detail"]')
    p store_time.inner_text.strip
    store_time.inner_text.strip.each_line do |line|
      timedetail = line.strip.scan(/(.*?)([\d:]+).+?([\d:]+)/)
      #p timedetail.length
      #p timedetail
      timedetail.each do |detailarray|
        if detailarray[0].empty? then
          p "全日" + " Open:" + detailarray[1] + " Close:" + detailarray[2]
          opening_time_weekday = detailarray[1]
          closing_time_weekday = detailarray[2]
          opening_time_saturday = detailarray[1]
          closing_time_saturday = detailarray[2]
          opening_time_holiday = detailarray[1]
          closing_time_holiday = detailarray[2]
        end
        if detailarray[0].include?("月") then
          p "平日" + " Open:" + detailarray[1] + " Close:" + detailarray[2]
          opening_time_weekday = detailarray[1]
          closing_time_weekday = detailarray[2]
          opening_time_saturday = detailarray[1]
          closing_time_saturday = detailarray[2]
          opening_time_holiday = detailarray[1]
          closing_time_holiday = detailarray[2]
        end
        if detailarray[0].include?("土") then
          p "土" + " Open:" + detailarray[1] + " Close:" + detailarray[2]
          opening_time_saturday = detailarray[1]
          closing_time_saturday = detailarray[2]
        end
        if detailarray[0].include?("日") then
          p "日" + " Open:" + detailarray[1] + " Close:" + detailarray[2]
          opening_time_holiday = detailarray[1]
          closing_time_holiday = detailarray[2]
        end
      end
    end
    p opening_time_weekday
    p closing_time_weekday
    p opening_time_saturday
    p closing_time_saturday
    p opening_time_holiday
    p closing_time_holiday
  
    store_holiday = store_info.xpath('.//td[.="定休日"]/following-sibling::node()[@class="detail"]').inner_text.strip
    p "定休日:" + store_holiday
    store_access = store_info.xpath('.//td[.="アクセス"]/following-sibling::node()[@class="detail"]').inner_text.strip
    p "アクセス:" + store_access
    store_address = store_info.xpath('.//td[.="住所"]/following-sibling::node()[@class="detail"]').inner_text.strip
    p "住所:" + store_address
    store_tel = store_info.xpath('.//td[.="電話番号"]/following-sibling::node()[@class="detail"]').inner_text.strip
    p "Tel:" + store_tel
    store_address_encode = URI.escape(store_address)
    json_geo_results = open("http://maps.googleapis.com/maps/api/geocode/json?address=#{store_address_encode}") do |io|
      JSON.load(io)
    end
  
    p "geo fetch:" + json_geo_results["status"]
    store_location = json_geo_results["results"].first["geometry"]["location"]
    lat = store_location["lat"]
    lng = store_location["lng"]
    p "lat:" + lat.to_s
    p "lng:" + lng.to_s 
  
    # 臨時情報
    store_notes = ""
    extra_info = doc.xpath('//article[contains(@class, "store")]//div[contains(@class, "col1")][3]')
    if extra_info.length > 0 then
      p "臨時：" + extra_info.xpath('div/h3').inner_text
      store_notes << extra_info.xpath('div/h3').inner_text
  
      # セミナー等
      linkboxes = extra_info.xpath('.//ul[contains(@class, "linkBoxContainer")]/li[contains(@class, "linkBox")]')
      linkboxes.each do |linkbox|
        linkheader = linkbox.xpath('.//p[contains(@class, "linkHeading")]')
        if linkheader.length > 0 then
          p "EventName:" + linkheader.inner_text
          event_details = linkheader.xpath('./following-sibling::p')
          event_details.each do |event_detail|
            p event_detail.inner_text
          end
        end
      end
  
      # 休業等
      hours_of_store = extra_info.xpath('.//ul[contains(@class, "hoursOfStore")]/li/span')
      hours_of_store.each do |hours_detail|
        p hours_detail.inner_text
        store_notes << "\r\n" + hours_detail.inner_text
      end
    end
  
    p "臨時店舗情報:" + store_notes
 
    # Timeで登録すると勝手にUTCで入るのでそれを利用する
    # Time.zone.parseはruby2.2でのrailsの不具合なのか動作しないので 
    p time_open_w = Time.parse(opening_time_weekday)
    p time_close_w = Time.parse(closing_time_weekday)
    p time_open_s = Time.parse(opening_time_saturday)
    p time_close_s = Time.parse(closing_time_saturday)
    p time_open_h = Time.parse(opening_time_holiday)
    p time_close_h = Time.parse(closing_time_holiday)
    #time_test = Time.zone.parse('2007-02-10 15:30:45')
    #p "タイムゾーン:" + time_test.to_s
    #test_time = Time.parse(opening_time_weekday)
 
    # 登録
    store_model = Store.new
    #store_model.attributes = { store_id: store_id, name: store_name, address: store_address, phone_number: store_tel, holiday: store_holiday, access: store_access, opening_time_weekday: opening_time_weekday, closing_time_weekday: closing_time_weekday, opening_time_saturday: opening_time_saturday, closing_time_saturday: closing_time_saturday, opening_time_holiday: opening_time_holiday, closing_time_holiday: closing_time_holiday, latitude: lat, longitude: lng, notes: store_notes, pref_id: pref_id }
    store_model.attributes = { store_id: store_id, name: store_name, address: store_address, phone_number: store_tel, holiday: store_holiday, access: store_access, opening_time_weekday: time_open_w, closing_time_weekday: time_close_w, opening_time_saturday: time_open_s, closing_time_saturday: time_close_s, opening_time_holiday: time_open_h, closing_time_holiday: time_close_h, latitude: lat, longitude: lng, notes: store_notes, pref_id: pref_id }
    reg_result = store_model.save
    p reg_result

  end
  
  def self.crawlstorebyprefid(prefid)
  
    doc = Nokogiri::HTML(open("http://www.starbucks.co.jp/store/search/result.php?search_type=1&pref_code=#{prefid}"))
  
    p doc.title
    result_stores = doc.xpath('//ul[contains(@class,"resultStores")]')
    store_links = result_stores.xpath('li[contains(@class, "item")]/a[@href]')
    p "links:" + store_links.length.to_s
  
    store_links.each do |node|
      sleep(4)

      store_url = node.attribute("href").value
      p "url:" + store_url
  
      crawlstorebystoreurl(store_url, prefid)
    end
  
  end
  
  def self.crawlstore
  
    for prefid in 19..19 do
  
      crawlstorebyprefid(prefid)
    end
  end
 
end
