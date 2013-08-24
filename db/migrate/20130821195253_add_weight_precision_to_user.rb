class AddWeightPrecisionToUser < ActiveRecord::Migration
  def change
    add_column :users, :weight_precision, :integer
  end
end
