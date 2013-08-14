# App.factory 'GearItem', ['$resource', ($resource) ->
App.factory 'GearLists', ['Restangular', (Restangular) ->
    # $resource('/api/gear/:id', {id: '@id'}, {update: {method: 'PUT'}})
    GearLists = Restangular.all 'gear_lists'

    return GearLists
]
