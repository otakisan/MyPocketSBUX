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
  # 商品個別ページをロード
  product_doc = Nokogiri::HTML(open(ROOT_URL + product_url))
  #p product_doc.title 

  # 詳細ページ:
  product_detail = product_doc.xpath('//article[contains(@class, "productDetail")]')
  #p "pdlen:" + product_detail.length.to_s
  product_name = product_detail.css('h2').inner_text
  p product_name

  # カテゴリ
  p category = /\/(\w+)(?:(?=\/\d+\/))/.match(product_url).to_a[1]

  # JANコード
  p jan_code = /\/(\d+)\//.match(product_url).to_a[1]

  # 通知（存在するものとそうでないものとある）
  p "notification:" + (notification = product_detail.css('div.productInfo > p.notification').inner_text)

  # 詳細ノード（リザーブなら豆の種類だけノードが発生する）
  detail_names = []
  detail_prices = []
  product_info_details = product_detail.xpath('//p[@class="productInfoDetail"]')
  # リザーブのときに４つしかないはずが、５つ返ってくる…
  #p "datailscount:" + product_info_details.length.to_s

  product_info_details.each do |pdi|
    detail_name = pdi.xpath('span[@class="name"]').inner_text
    if detail_name != "" then
      p "detail:" + detail_name
      detail_names << detail_name
    end

    # sizeListが存在する場合には、下記の要素は存在しないはず
    detail_price = pdi.xpath('span[@class="price"]').inner_text
    if detail_price != "" then
      detail_prices << detail_price
      p detail_price
    end
  end

  # サイズ定義（リザーブのときは重複するのでdistinctする。全てサイズ定義が同じ前提）
  size_set = product_detail.xpath('//ul[@class="sizeList"]//span[@class="size"]')
  size_defs = size_set.map{|size_def| size_def.inner_text}
  # サイズの情報がなければN/A
  if size_defs.length == 0 then
    size_defs << "na"
  end
  # フラペはShortも可能（キャンペーン品でワンサイズのこともあるが都度対応）
  if product_name.include?("フラペチーノ") then
    size_defs.unshift("Short")
  end
  size_defs.uniq!
  p "サイズ定義：" + size_defs.to_s

  # サイズ違いあり：Tall
  # サイズを示す要素があるか
  size_tall_set = product_detail.xpath('//ul[@class="sizeList"]//span[@class="size" and (self::node()="Tall" or self::node()="Doppio")]')
  if size_tall_set != nil && size_tall_set.length > 0 then

    size_tall_set.each do |size_tall|
      p "Size:" + size_tall.inner_text
      product_price = size_tall.xpath('following-sibling::node()[@class="price"]').inner_text 
      p size_tall.inner_text + " Price:" + product_price
      detail_prices << product_price
    end
  else
=begin
    product_price = product_detail.xpath('//p[@class="productInfoDetail"]//span[@class="price"]').inner_text
    p product_price
=end
  end

  product_special = product_detail.xpath('//div[@class="productInfo"]//p[@class="specialItem"]').inner_text
  p "Special:" + product_special

  # ミルク定義
  p milk = ["ラテ", "キャラメル", "カプチーノ", "ココア", "モカ", "ミスト", "フラペチーノ" ].any? { |milkkeyword| product_name.include?(milkkeyword) && !product_name.include?("マンゴー") } ? "whole/two-percent/nonfat/soy" : "na"

  # リザーブのときは、詳細に豆（価格）の情報として盛り込む
  if ["1111111111111", "2222222222222"].any?{|janc| jan_code == janc} then
    p "zip前names:" + detail_names.to_s
    p "zip前prices:" + detail_prices.to_s
    new_detail_names = []
    detail_names.zip(detail_prices) {|elements| new_detail_names <<  elements.join(":") }
    p new_detail_names.to_s
    detail_names = new_detail_names
  end

  # 登録
  p "name:" + product_name
  p "category:" + category
  p "jan_code:" + jan_code
  p "price:" + detail_prices.first.to_s
  p "special:" + product_special
  p "notes:" + detail_names.join("\t")
  p "notification:" + notification
  p "size:" + size_defs.join("\t")
  p "milk:" + milk 

end

doc = Nokogiri::HTML(open("http://www.starbucks.co.jp/beverage/"))

p doc.title
doc.xpath('//article[contains(@class,"productList")]').each do |node|

  p "オススメ"
  node.xpath('//li[@class="col recommend"]').each do |recommended|
    #traceoutproduct(recommended)
    product(recommended)
  end

  p "レギュラー"
  node.xpath('//li[@class="col "]').each do |regular|
    #traceoutproduct(regular)
    product(regular)
  end

end

