class CreateGearItemsGearListsTable < ActiveRecord::Migration
  def change
    create_table :gear_items_gear_lists do |t|
      t.integer :gear_item_id
      t.integer :gear_list_id
    end
  end
end
