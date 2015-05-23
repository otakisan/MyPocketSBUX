class TastingLog < ActiveRecord::Base
  belongs_to :store
  belongs_to :order
end
