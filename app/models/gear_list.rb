class GearList < ActiveRecord::Base
  attr_accessible :name

  #relations
  belongs_to :user

  #validations
  validates :name, :presence => true

end
