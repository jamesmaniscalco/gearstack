App.controller 'GearController', ['$scope', 'Restangular', ($scope, Restangular) ->
    gearItems = Restangular.all('gear_items')
    $scope.gearItems = gearItems.getList()

    # DOM manipulation
    $scope.gearFormVisible = false

    $scope.showGearForm = ->
        $scope.gearFormVisible = true

    $scope.hideGearForm = ->
        $scope.gearFormVisible = false

    # controller functions
    $scope.refreshGearItems = ->
        $scope.gearItems = gearItems.getList()

    $scope.addGearItem = ->
        # post gear item to server
        gearItems.post($scope.gearItem).then (addedGearItem) ->
            # push the new item into the table
            $scope.gearItems.push addedGearItem
            # $scope.refreshGearItems()
            # if it works, hide the form (Should this go in a separate file?  A directive?)
            $scope.hideGearForm()
            # then delete object from the scope
            $scope.gearItem = {}
        , ->
            console.log 'error posting GearItem'

  ]
