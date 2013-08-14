class GearList < ActiveRecord::Base
  attr_accessible :name

  #relations
  belongs_to :user
  has_and_belongs_to_many :gear_items

  #validations
  validates :name, :presence => true

end
