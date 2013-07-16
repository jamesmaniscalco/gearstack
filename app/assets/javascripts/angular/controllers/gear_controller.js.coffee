App.controller 'GearController', ['$scope', 'Restangular', ($scope, Restangular) ->
    gearItems = Restangular.all('gear_items')
    $scope.gearItems = gearItems.getList()

    $scope.addGearItem = ->
      console.log('trying to save gearItem')
      console.log($scope.gearItem)
      # gearItem = GearItem.save $scope.gearItem, (gearItem) ->
      #   console.log('successfully created item') 
      #   $scope.gearItems.push(gearItem)
      gearItems.post $scope.gearItem, (response) ->
        console.log(response)
        console.log('successfully posted item')
        $scope.gearItems.push $scope.gearItem
        console.log 'pushed item'
  ]
