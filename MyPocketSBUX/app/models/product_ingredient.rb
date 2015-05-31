class ProductIngredient < ActiveRecord::Base
  belongs_to :order_detail
end
