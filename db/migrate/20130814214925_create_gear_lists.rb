class CreateGearLists < ActiveRecord::Migration
  def change
    create_table :gear_lists do |t|
      t.string :name
      t.integer :user_id
    end
  end
end
