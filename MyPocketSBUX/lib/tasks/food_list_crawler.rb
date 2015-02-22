require 'open-uri'
require 'nokogiri'


def traceoutproduct(node)

  # tilte
  p node.css('h3').inner_text

  # 記事のサムネイル画像
  #p node.css('img').attribute('src').value

  # 記事のサムネイル画像
  p node.css('a').attribute('href').value
end

doc = Nokogiri::HTML(open("http://www.starbucks.co.jp/food/"))

p doc.title
doc.xpath('//article[contains(@class,"productList")]').each do |node|

  p "オススメ"
  node.xpath('//li[@class="col recommend"]').each do |recommended|
    traceoutproduct(recommended)
  end

  p "レギュラー"
  node.xpath('//li[@class="col "]').each do |regular|
    traceoutproduct(regular)
  end

end

