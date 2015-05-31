class OrderDetail < ActiveRecord::Base
  belongs_to :order
  has_many :product_ingredients, :dependent => :delete_all
  accepts_nested_attributes_for :product_ingredients
end
