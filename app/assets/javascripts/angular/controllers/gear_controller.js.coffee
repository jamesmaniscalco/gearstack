App.controller 'GearController', ['$scope', 'GearItem', ($scope, GearItem) ->
    $scope.gearItems = GearItem.query()
]
