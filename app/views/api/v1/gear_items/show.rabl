# RABL for which attributes we want to expose with the API

object @gear_item

# properties to include:
attributes :id, :name, :description, :weight, :location, :owner_id, :possessor_id

node :status do |gear_item|
    if gear_item.possessor == current_user
        gear_item.status
    else
        'onloan'
    end
end