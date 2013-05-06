#routes, update as necessary from rake routes output.
gear_url = (scope) ->
    switch scope
        when 'all' then 'gear.json'

populateGear = (scope, destination) ->
  $.get (gear_url scope), null, (data) ->
    $(destination).append HandlebarsTemplates['gear_items/list'](data)

$(->
  populateGear 'all', '#gear-table > tbody'
)
