class GearItem < ActiveRecord::Base
  attr_accessible :name, :description, :weight, :location, :status

  #relations
  belongs_to :owner, :class_name => "User"
  belongs_to :possessor, :class_name => "User"
end
