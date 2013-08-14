class GearItem < ActiveRecord::Base
  attr_accessible :name, :description, :weight, :location, :status

  #relations
  belongs_to :owner, :class_name => "User"
  belongs_to :possessor, :class_name => "User"
  has_and_belongs_to_many :gear_lists

  #validations
  validates :name, :presence => true
  validates :status, :presence => true
  validates :weight, :numericality => true, :allow_nil => true
  validates :status, :inclusion => { :in => %w(checkedin checkedout)}

  #scopes
  scope :all_for_user, lambda { |user| where("(owner_id = ?) OR (possessor_id = ?)", user.id, user.id) }
end
