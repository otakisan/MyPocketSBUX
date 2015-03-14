require 'poppler'
require 'open-uri'
require 'nkf'


def tocsvline(strs, nums)
  p strs
  p nums

  csvs = []
  for index in 0..(nums.length-1)
    csvs << strs[strs.length-nums.length+index] + "," + nums[index].to_s
  end

  return csvs
end

def linestocsv(lines)
  numerics = []
  strs = []
  csvlines = []

  lines.each do |line|
    asciichar = NKF.nkf('-m0Z1 -w', line)
    num = asciichar.to_i
    if num == 0 then

      if numerics.length > 0 then
        csvlines << tocsvline(strs, numerics)
        numerics = []
        strs = []
      end
      if !(["Pastry", "Sandwich", "Dessert", "PackageFood"].any?{|header| asciichar.include?(header) }) then
        strs << asciichar
      else
        p "other2:" + asciichar
      end  
    elsif num > 0 then
      numerics << num
    else
      p "other:" + asciichar
    end
  end

  #p numerics
  #p strs
  #p csvlines
  # 個別の配列をつなぎあわせる
  cal_array = []
  csvlines.each {|line| cal_array.concat(line) }
  p cal_array

end

def dispatcharrays(lines)
  calories = []
  drink_entries = []

  # カスタマイズアイテムは現時点では処理しない
  lines.each do |line|
    if line.include?("トッピング量") then
      break
    end

    # ストレートティー系は固定でゼロとするため処理しない
    # 扱う必要が出たら、line == "0"も加え、ゼロそのものも扱うようにする
    calorie = line.to_i
    if line > 0 then
      calories << calorie
    else
      # 商品マスタからデータを取得
      #Drink.find(:all, :conditions => ["name = ?", line])
      drinks = Drink.where("name = ?", line)
      if drinks.length == 0 then
        drink_model = drinks.first

        # 名称
        p product_name = drink_model.name

        # JANコード
        p jan_code = drink_model.jan_code

        # サイズ
        size_defs = drink_model.size.split("\t")
        p size_defs.to_s

        # ミルク
        milk_defs = drink_model.milk.split("\t")
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
        size_defs.each do |size_def|
          liquid_temps.each do |liquid_temp|
            milk_defs.each do |milk_def|
              drink_entries << [product_name, jan_code, size_def, liquid_temp, milk_def]
            end
          end
        end

      elsif drinks.length > 1 then
        p drinks.each { |drink_model| p drink_model.name }
      end
    end
  end

  p drink_entries.to_s
  p calroies.to_s

end

def crawldrinknutrition
  nutrition = Poppler::Document.new(open("http://www.starbucks.co.jp/assets/images/web2/images/allergy/pdf/allergen-beverage.pdf").read)
  #page_num = nutrition.get_n_pages()
  page_num = nutrition.pages.length
  
  all_page_text = ""
  for index in 0..(page_num-1)
    page = nutrition.pages[index]
    all_page_text.concat(page.get_text)
  end
  
  lines = all_page_text.split("\n")
  f = lines.select { |line| line.length >= 1 && line[1] != " " && !(["品目）", "ル 肉 み","特定原材料"].any? {|rmstr| line.include?(rmstr)}) && !(["・", "＜", "●", "―", "ー", "-"].any? {|w| w == line[0]}) }
  p f

  #dispatcharrays(f) 
  #linestocsv(f)
  
  File.open("drink_nutrition.txt", 'w+') do | writer |
    f.each do | item |
      writer << item + "\n"
    end
  end

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

crawldrinknutrition

