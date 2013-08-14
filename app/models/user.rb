class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body

  has_many :gear_items_owned, :class_name => 'GearItem', :foreign_key => 'owner_id'
  has_many :gear_items_possessed, :class_name => 'GearItem', :foreign_key => 'possessor_id'
  has_many :gear_lists
end
