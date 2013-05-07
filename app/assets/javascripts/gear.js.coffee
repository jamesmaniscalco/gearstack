#routes, update as necessary from rake routes output.
gear_url = (scope) ->
  switch scope
    when 'all' then 'gear.json'

new_gear_url = 'gear/new.json'


populateGear = (scope, destination) ->
  $.get (gear_url scope), null, (data) ->
    $(destination).append HandlebarsTemplates['gear_items/list'](data)

getGearItemForm = (destination) ->
  $.get new_gear_url, null, (data) ->
    $(destination).after HandlebarsTemplates['gear_items/show'](data)

newGearItem = ->
  null

$(->
  populateGear 'all', '#gear-table > tbody'
  getGearItemForm '#gear-table > tbody > tr:last'

)
