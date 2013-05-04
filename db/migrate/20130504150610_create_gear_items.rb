class CreateGearItems < ActiveRecord::Migration
  def change
    create_table :gear_items do |t|
      t.string :name
      t.text :description
      t.integer :owner_id
      t.integer :possessor_id
      t.float :weight
      t.string :location

      t.timestamps
    end
  end
end
