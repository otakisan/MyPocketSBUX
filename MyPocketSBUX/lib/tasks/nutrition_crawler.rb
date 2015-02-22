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
  p csvlines
end

nutrition = Poppler::Document.new(open("http://www.starbucks.co.jp/assets/images/web2/images/allergy/pdf/allergen-food.pdf").read)
#page_num = nutrition.get_n_pages()
page_num = nutrition.pages.length

all_page_text = ""
for index in 0..(page_num-1)
  page = nutrition.pages[index]
  all_page_text.concat(page.get_text)
end

lines = all_page_text.split("\n")
f = lines.select { |line| line.length >= 3 && line[1] != " " && !(["品目）", "ル 肉 み","特定原材料"].any? {|rmstr| line.include?(rmstr)}) && !(["・", "＜", "●", "―", "ー", "-"].any? {|w| w == line[0]}) }
#p f

linestocsv(f)

=begin
File.open("ft2.txt", 'w+') do | writer |
  f.each do | item |
    writer << item + "\n"
  end
end
=end

=begin
File.open("nut2.txt", "w+") do |io|
  #io.write nutrition.first.get_text
  for index in 0..(page_num-1)
    page = nutrition.pages[index]
    io.write page.get_text
  end
end
=end

