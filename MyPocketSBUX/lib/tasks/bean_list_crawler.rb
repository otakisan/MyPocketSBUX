require 'open-uri'
require 'nokogiri'

ROOT_URL = "http://www.starbucks.co.jp"


def beandetail(url)
  
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

  if !bean_name.include?("セット") then
    p bean_name
    p bean_price
    p /\/(\d+)\//.match(url).to_a[1]
    p product_special
  end

end

def crawlbean
  doc = Nokogiri::HTML(open("http://www.starbucks.co.jp/beans/"))

  p doc.title
  #doc.xpath('//article[contains(@class,"productList")]').each do |node|
  doc.css('body > div.mainContents.notExNav > article > ul.row.listGrid.js-component > li.col.seasonal,li.col.reserve,li.col.blonde,li.col.medium,li.col.dark').each do |node|
    #p node.inner_text
    beandetail(ROOT_URL + node.css('a').first.attribute("href").value)

  end
end

crawlbean

