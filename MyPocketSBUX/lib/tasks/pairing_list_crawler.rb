require 'open-uri'
require 'nokogiri'

ROOT_URL = "http://www.starbucks.co.jp"


def crawlpairing

  doc = Nokogiri::HTML(open("http://www.starbucks.co.jp/pairing/coffee.html"))

  p doc.title
  pair_list = doc.xpath('//article//div[contains(@class,"withCarouselCol")]')
  pair_list.each do |pair|

    bean_code = /\/(\d+)\//.match(pair.xpath('p[@class="imgL"]//a[@href]').first.attribute("href").value).to_a[1]
    bean_name = pair.xpath('p[@class="imgL"]//a[@href]/span[contains(@class, "txtLink")]').inner_text
    p bean_code + ":" + bean_name

    food_list = pair.xpath('div[@class="colR"]//li[contains(@class, "carouselItem")]')
    food_list.each do |food|
      food_code = /\/(\d+)\//.match(food.xpath('a[@href]').first.attribute("href").value).to_a[1]
      food_name = food.xpath('a[@href]/span').inner_text
      p food_code + ":  " + food_name
    end

  end

end


crawlpairing

