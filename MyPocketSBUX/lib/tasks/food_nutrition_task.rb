require "#{Rails.root}/app/models/food"
require "#{Rails.root}/app/models/nutrition"
require 'open-uri'
require 'nokogiri'
require 'json'
require 'nkf'

ROOT_URL = "http://www.starbucks.co.jp"
 
class Tasks::FoodNutritionTask
  def self.execute
    Rails.logger.debug("FoodNutritionTask start...")
    regstryfromfile
    Rails.logger.debug("FoodNutritionTask end...")
  end

  def self.tocsvline(strs, nums)
    p strs
    p nums
  
    csvs = []
    for index in 0..(nums.length-1)
      csvs << strs[strs.length-nums.length+index] + "," + nums[index].to_s
    end
  
    return csvs
  end
  
  def self.linestocsv(lines)
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
    # 商品名, カロリー
    cal_array = []
    csvlines.each {|line| cal_array.concat(line) }
    p cal_array

    return cal_array  
  end

  def self.registerfromcsv(food_nut_csv)
    allfoods = Food.all
    food_nut_csv.each do |nut_csv_line|
      nuts = nut_csv_line.split(",")
      food_name_csv = nuts[0].strip
      food_calorie_csv = nuts[1].strip.to_i

      # 通常ならあり得ないけど、全角・半角の変換ができないので
      #food_models = Food.where('name = ?', food_name_csv)
      food_model = findambiguously(allfoods, food_name_csv)
      if food_model != nil then
        # 登録データ取得
        p "Found : #{food_model.name}"

        # JAN
        jan_code = food_model.jan_code
        # サイズ
        size = "na"
        # 液温
        liquid_temperature = "na"
        # ミルク
        milk = "na"
        # カロリー
        calorie = food_calorie_csv

        # 登録
        nutrition_model = Nutrition.new
        nutrition_model.attributes = { jan_code: jan_code, size: size, liquid_temperature: liquid_temperature, milk: milk, calorie: calorie }
        p nutrition_model.save
     else
        p "!!!NoData!!!: #{food_name_csv}"
      end
    end
  end

  def self.findambiguously(food_models, foodname)
    # いずれも半角に寄せる
    adjusted_name = NKF.nkf('-m0Z0Z1 -w', foodname)
    # ()書きの注釈を消す
    adjusted_name = adjusted_name.gsub(/\((?!根菜チキン).+\)/, "").strip
    #p "調整後文字列:" + adjusted_name

    # 比較 完全一致がなければ、整形後文字列での部分一致（一致タイプによる得点付けの内、最も高い点数のものを選択する、というフィルタが可能であればそちらで）
    result_model = nil
=begin
    found_models = food_models.select { |food_model| 
      food_model_name_adjusted = NKF.nkf('-m0Z0Z1 -w', food_model.name)
      food_model_name_adjusted == adjusted_name || adjusted_name.gsub(/[\u0020-\u007F]/, "").include?(food_model_name_adjusted.gsub(/[\u0020-\u007F]/, "")) 
    }
=end
    found_models = food_models.select { |food_model| NKF.nkf('-m0Z0Z1 -w', food_model.name) == adjusted_name}
    if found_models.length > 0 then
      result_model = found_models.first
    else
      found_models = food_models.select { |food_model| adjusted_name.gsub(/[\u0020-\u007F]/, "").include?(NKF.nkf('-m0Z0Z1 -w', food_model.name).gsub(/[\u0020-\u007F]/, "")) }
      if found_models.length > 0 then
        result_model = found_models.first
      end
    end

    return result_model
  end

  def self.regstryfromfile
    #nut_text = File.read("/Users/takashi/Documents/dev/201502/MyPocketSBUX/rails/MyPocketSBUX/MyPocketSBUX/lib/tasks/food_nutrition.txt")
    nut_text = File.read("./lib/tasks/food_nutrition.txt")
    lines = nut_text.split("\n")
    f = lines.select { |line| line.length >= 1 && line[1] != " " && !(["品目）", "ル 肉 み","特定原材料"].any? {|rmstr| line.include?(rmstr)}) && !(["・", "＜", "●", "―", "ー", "-"].any? {|w| w == line[0]}) }
    p f

    csvdata = linestocsv(f)
    registerfromcsv(csvdata)

  end

end

