class AddWeightUnitToUser < ActiveRecord::Migration
  def change
    add_column :users, :weight_unit, :string
  end
end
