require 'open-uri'
require 'nokogiri'

ROOT_URL = "http://www.starbucks.co.jp"


def crawlpressreleasebyfiscalyear(fiscalyear)

  doc = Nokogiri::HTML(open("http://www.starbucks.co.jp/press_release/pr#{fiscalyear}.php"))

  p doc.title
  release_list = doc.xpath('//article//ul[contains(@class,"linkList")]/li')
  #store_links = result_stores.xpath('li[contains(@class, "item")]/a[@href]')
  #p "links:" + store_links.length.to_s

  release_list.each do |node|
    release_url = node.xpath('a[@href!=""]')
    if release_url.length > 0 then
      p release_url[0].attribute("href").value
    end

    p fisandid = /\/pr(\d+)-(\d+)/.match(release_url.first.attribute("href").value).to_a
    p "fis_y:" + fisandid[1]
    p "pr_id:" + fisandid[2]
    #p "url:" + release_url
    heading = node.xpath('.//p[@class="heading"]').inner_text
    p heading
    #crawlstorebystoreurl(store_url)
  end

end

def crawlpressrelease

  #for fiscalyear in 2013..2014 do
  for fiscalyear in 2014.step(2012, -1) do
    crawlpressreleasebyfiscalyear(fiscalyear)
  end

end

crawlpressrelease


