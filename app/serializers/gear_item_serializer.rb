class GearItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :weight, :location, :status
end
