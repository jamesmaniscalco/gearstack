class AddStatusToGearItems < ActiveRecord::Migration
  def change
    add_column :gear_items, :status, :string
  end
end
