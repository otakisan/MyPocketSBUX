require 'open-uri'
require 'nokogiri'

ROOT_URL = "http://www.starbucks.co.jp"

def crawlstorebystoreurl(store_url)
  doc = Nokogiri::HTML(open(store_url))
  store_name = doc.xpath('//article[contains(@class,"store")]/header/h2').inner_text
  p "StoreName:" + store_name
  #p store_url
  store_id = /id=(\d+)/.match(store_url).to_a[1]
  p "Store ID:" + store_id.to_s

  store_info = doc.xpath('//table[contains(@class, "storeInfo")]')

  store_time = store_info.xpath('.//td[.="営業時間"]/following-sibling::node()[@class="detail"]')
  p store_time.inner_text.strip
  store_time.inner_text.strip.each_line do |line|
    timedetail = line.strip.scan(/(.*?)([\d:]+).+?([\d:]+)/)
    #p timedetail.length
    #p timedetail
    timedetail.each do |detailarray|
      if detailarray[0].empty? then
        p "全日" + " Open:" + detailarray[1] + " Close:" + detailarray[2]
      end
      if detailarray[0].include?("月") then
        p "平日" + " Open:" + detailarray[1] + " Close:" + detailarray[2]
      end
      if detailarray[0].include?("土") then
        p "土" + " Open:" + detailarray[1] + " Close:" + detailarray[2]
      end
      if detailarray[0].include?("日") then
        p "日" + " Open:" + detailarray[1] + " Close:" + detailarray[2]
      end
    end
  end

  store_holiday = store_info.xpath('.//td[.="定休日"]/following-sibling::node()[@class="detail"]')
  p store_holiday.inner_text.strip
  store_access = store_info.xpath('.//td[.="アクセス"]/following-sibling::node()[@class="detail"]')
  p store_access.inner_text.strip
  store_address = store_info.xpath('.//td[.="住所"]/following-sibling::node()[@class="detail"]')
  p store_address.inner_text.strip
  store_tel = store_info.xpath('.//td[.="電話番号"]/following-sibling::node()[@class="detail"]')
  p store_tel.inner_text.strip

  # 臨時情報
  extra_info = doc.xpath('//article[contains(@class, "store")]//div[contains(@class, "col1")][3]')
  if extra_info.length > 0 then
    p "臨時：" + extra_info.xpath('div/h3').inner_text

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
    end

  end
end

def crawlstorebyprefid(prefid)

  doc = Nokogiri::HTML(open("http://www.starbucks.co.jp/store/search/result.php?search_type=1&pref_code=#{prefid}"))

  p doc.title
  result_stores = doc.xpath('//ul[contains(@class,"resultStores")]')
  store_links = result_stores.xpath('li[contains(@class, "item")]/a[@href]')
  p "links:" + store_links.length.to_s

  store_links.each do |node|
    store_url = node.attribute("href").value
    p "url:" + store_url

    crawlstorebystoreurl(store_url)
  end

end

def crawlstore

  for prefid in 19..19 do

    crawlstorebyprefid(prefid)
  end
end

#crawlstore
crawlstorebystoreurl("http://www.starbucks.co.jp/store/search/detail.php?id=888")

# 営業時間
crawlstorebystoreurl("http://www.starbucks.co.jp/store/search/detail.php?id=420")
crawlstorebystoreurl("http://www.starbucks.co.jp/store/search/detail.php?id=772")
crawlstorebystoreurl("http://www.starbucks.co.jp/store/search/detail.php?id=705")

# 臨時情報
crawlstorebystoreurl("http://www.starbucks.co.jp/store/search/detail.php?id=249")
crawlstorebystoreurl("http://www.starbucks.co.jp/store/search/detail.php?id=197")
