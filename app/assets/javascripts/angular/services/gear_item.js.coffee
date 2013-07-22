# App.factory 'GearItem', ['$resource', ($resource) ->
App.factory 'GearItems', ['Restangular', (Restangular) ->
    # $resource('/api/gear/:id', {id: '@id'}, {update: {method: 'PUT'}})
    GearItems = Restangular.all 'gear_items'

    return GearItems
]
