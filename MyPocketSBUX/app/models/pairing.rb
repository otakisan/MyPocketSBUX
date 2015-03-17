class Pairing < ActiveRecord::Base
  belongs_to :bean
  belongs_to :food
end
