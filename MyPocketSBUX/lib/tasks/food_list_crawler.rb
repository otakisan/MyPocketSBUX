require 'open-uri'
require 'nokogiri'

ROOT_URL = "http://www.starbucks.co.jp"

def traceoutproduct(node)

  # tilte
  p node.css('h3').inner_text

  # 記事のサムネイル画像
  #p node.css('img').attribute('src').value

  # 記事のサムネイル画像
  p node.css('a').attribute('href').value
end

def product(node)
  
  product_url = node.css('a').attribute('href').value
  product_doc = Nokogiri::HTML(open(ROOT_URL + product_url))
  #p product_doc.title 

  product_detail = product_doc.xpath('//article[contains(@class, "productDetail")]')
  product_name = product_detail.css('h2').inner_text
  product_price = product_detail.xpath('//p[@class="productInfoDetail"]//span[@class="price"]').inner_text
  p product_name
  p product_price

  product_special = product_detail.xpath('//div[@class="productInfo"]//p[@class="specialItem"]/span').inner_text
  p product_special
end

doc = Nokogiri::HTML(open("http://www.starbucks.co.jp/food/"))

p doc.title
doc.xpath('//article[contains(@class,"productList")]').each do |node|

  p "オススメ"
  node.xpath('//li[@class="col recommend"]').each do |recommended|
    #traceoutproduct(recommended)
    #product(recommended)
  end

  p "レギュラー"
  node.xpath('//li[@class="col "]').each do |regular|
    #traceoutproduct(regular)
    product(regular)
  end

end

