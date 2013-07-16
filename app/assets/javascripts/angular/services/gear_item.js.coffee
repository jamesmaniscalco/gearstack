App.factory 'GearItem', ['$resource', ($resource) ->
    $resource('/api/gear/:id', {id: '@id'}, {update: {method: 'PUT'}})
]
