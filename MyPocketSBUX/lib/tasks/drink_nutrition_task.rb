require "#{Rails.root}/app/models/drink"
#require "#{Rails.root}/app/models/nutrition"
require 'open-uri'
require 'nokogiri'
# popplerのロードがよくわからないので、後回しにし、あらかじめ出力済みのテキストを解析する
#require "#{ENV['INSTALLATION DIRECTORY']}/gems/poppler-2.2.4/lib/poppler"
#require "/Users/takashi/.rbenv/versions/2.2.0/lib/ruby/gems/2.2.0/gems/poppler-2.2.4/lib/poppler"
require 'json'

ROOT_URL = "http://www.starbucks.co.jp"
 
class Tasks::DrinkNutritionTask
  def self.execute
    Rails.logger.debug("DrinkNutritionTask start...")
    #crawlstorebystoreurl("http://www.starbucks.co.jp/store/search/detail.php?id=888")
    regstryfromfile
    #crawldrinknutrition
    Rails.logger.debug("DrinkNutritionTask end...")
  end

  def self.dispatcharrays(lines)
    calories = []
    drink_entries = []
    section_seq = 0
  
    # カスタマイズアイテムは現時点では処理しない
    lines.each_with_index do |line, index|
      # データ取得の終了判定
      if line.include?("トッピング量") then
        break
      end

      # 商品をセクションごとに区切り、スプレッド上での作業を軽減する
      if ["期間限定", "コーヒー（Brewed Coffee）", "エスプレッソ（Espresso)", "フラペチーノ®（Frappuccino® Blended Beverage）", "その他ドリンク（Other Beverage）", "カスタマイズ（Discover Your Starbucks)"].any? {|rmstr| line.include?(rmstr)} then
        section_seq += 1
      end
 
      # ストレートティー系は固定でゼロとするため処理しない
      # 扱う必要が出たら、line == "0"も加え、ゼロそのものも扱うようにする
      calorie = /^\d+$/.match(line).to_a.first.to_i
      if calorie > 0 then
        calories << calorie
      else
        # 商品マスタからデータを取得
        # マスタに存在するものをファイルへの出力対象とする
        #Drink.find(:all, :conditions => ["name = ?", line])
        p line
        line.slice!("ホット")
        p line
        drinks = Drink.where("name = ?", line.strip)
        if drinks.length == 1 then
          drink_model = drinks.first
  
          # 名称
          p product_name = drink_model.name
  
          # JANコード
          p jan_code = drink_model.jan_code
  
          # サイズ
          size_defs = drink_model.size.split("\t")
          p size_defs.to_s
  
          # ミルク
          milk_defs = drink_model.milk.split("/")
          p milk_defs.to_s
  
          # 液温
          liquid_temps = []
          if drink_model.notes.include?("HOT") then
            liquid_temps << "HOT"
          end
          if drink_model.notes.include?("ICED") then
            liquid_temps << "ICED"
          end
          if liquid_temps.length == 0 then
            liquid_temps << "na"
          end
  
          # サイズ×液温×ミルク
          size_defs.each_with_index do |size_def, size_order|
            liquid_temps.each do |liquid_temp|
              milk_defs.each do |milk_def|
                #drink_entries << [section_seq, index.to_s, (size_def == "Solo" ? "4" : (size_def == "Doppio" ? "5" : size_order.to_s)), product_name, jan_code, size_def, liquid_temp, milk_def]
                drink_entries << [section_seq, (size_def == "Solo" ? "4" : (size_def == "Doppio" ? "5" : size_order.to_s)), index.to_s, (liquid_temp.first == 'H' ? 0 : liquid_temp.first == 'I' ? 2 : 3), (milk_def == "whole" ? 0 : milk_def == "two-percent" ? 1 : milk_def == "nonfat" ? 2 : 3), product_name, jan_code, size_def, liquid_temp, milk_def]
              end
            end
          end
  
        elsif drinks.length > 1 then
          p drinks.each { |drink_model| p drink_model.name }
        end
      end
    end

    # サイズごとにまとめて、手動でのカロリーとの突き合わせ作業を軽減する
    drink_entries.sort! do |lhs, rhs|
      (lhs[0].to_i <=> rhs[0].to_i).nonzero? || (lhs[1].to_i <=> rhs[1].to_i).nonzero? || (lhs[2].to_i <=> rhs[2].to_i).nonzero? || (lhs[3] <=> rhs[3]).nonzero? || (lhs[4] <=> rhs[4])
    end
  
    p drink_entries.to_s
    p calories.to_s
  
    p "entry:" + drink_entries.length.to_s
    p "cals:" + calories.length.to_s

    File.write("drink_nutrition_entries.txt", (drink_entries.map { |entry| entry.join("\t") }).join("\n"))
    File.write("drink_cals.txt", calories.join("\n"))
  end
  
  def writearraytofilewithjoin(arr, filepath)
    File.open(filepath, 'w+') do | writer |
      arr.each do | item |
        writer << item + "\n"
      end
    end 
  end

  def self.crawldrinknutrition
    nutrition = Poppler::Document.new(open("http://www.starbucks.co.jp/assets/images/web2/images/allergy/pdf/allergen-beverage.pdf").read)
    #page_num = nutrition.get_n_pages()
    page_num = nutrition.pages.length
    
    all_page_text = ""
    for index in 0..(page_num-1)
      page = nutrition.pages[index]
      all_page_text.concat(page.get_text)
    end
    
    lines = all_page_text.split("\n")
    f = lines.select { |line| line.length >= 3 && line[1] != " " && !(["品目）", "ル 肉 み","特定原材料"].any? {|rmstr| line.include?(rmstr)}) && !(["・", "＜", "●", "―", "ー", "-"].any? {|w| w == line[0]}) }
    p f
  
    dispatcharrays(f) 
    #linestocsv(f)
    
=begin
    File.open("ft2.txt", 'w+') do | writer |
      f.each do | item |
        writer << item + "\n"
      end
    end
=end
  
=begin  
    File.open("drink_nut.txt", "w+") do |io|
      #io.write nutrition.first.get_text
      for index in 0..(page_num-1)
        page = nutrition.pages[index]
        io.write page.get_text
      end
    end
=end
  end

  def self.regstryfromfile
    nut_text = File.read("/Users/takashi/Documents/dev/201502/MyPocketSBUX/rails/MyPocketSBUX/MyPocketSBUX/lib/tasks/drink_nutrition.txt")
    lines = nut_text.split("\n")
    f = lines.select { |line| line.length >= 1 && line[1] != " " && !(["品目）", "ル 肉 み","特定原材料"].any? {|rmstr| line.include?(rmstr)}) && !(["・", "＜", "●", "―", "ー", "-"].any? {|w| w == line[0]}) }
    p f

    dispatcharrays(f)

  end

end

