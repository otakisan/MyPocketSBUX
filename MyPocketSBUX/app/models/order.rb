class Order < ActiveRecord::Base
  belongs_to :store
  has_many :order_details, :dependent => :destroy
  accepts_nested_attributes_for :order_details
end
