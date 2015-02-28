require 'open-uri'
require 'nokogiri'

ROOT_URL = "http://www.starbucks.co.jp"


def crawlpairing

  doc = Nokogiri::HTML(open("http://www.starbucks.co.jp/pairing/coffee.html"))

  p doc.title
  pair_list = doc.xpath('//article//div[contains(@class,"withCarouselCol")]')
  pair_list.each do |pair|

    p bean_code = pair.xpath('p[@class="imgL"]//a[@href]').first.attribute("href").value
    p bean_name = pair.xpath('p[@class="imgL"]//a[@href]/span[contains(@class, "txtLink")]').inner_text

    food_list = pair.xpath('div[@class="colR"]//li[contains(@class, "carouselItem")]')
    food_list.each do |food|
      p food_code = food.xpath('a[@href]').first.attribute("href").value
      p food_name = food.xpath('a[@href]/span').inner_text
    end

  end

end


crawlpairing

