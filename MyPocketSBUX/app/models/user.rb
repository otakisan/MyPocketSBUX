class User < ActiveRecord::Base
  validates :my_pocket_id, presence: true, uniqueness: true
end
