# App.controller 'GearController', ['$scope', 'Restangular', ($scope, Restangular) ->
App.controller 'GearController', ['$scope', '$q', 'resolvedGearItems', 'GearItems', 'UserStatus', ($scope, $q, resolvedGearItems, GearItems, UserStatus) ->
    # pull in data from the resolve in the $routeProvider
    if resolvedGearItems.status = true
        $scope.gearItems = resolvedGearItems.data
    else
        console.log 'error'
        console.log resolvedGearItems.data

    # DOM manipulation
    $scope.gearFormVisible = false

    $scope.showGearForm = ->
        $scope.gearFormVisible = true

    $scope.hideGearForm = ->
        $scope.gearFormVisible = false

    $scope.itemIsCheckedIn = (gearItem) ->
        if gearItem.status == 'checkedin'
            true
        else
            false

    $scope.itemIsCheckedOut = (gearItem) ->
        if gearItem.status == 'checkedout'
            true
        else
            false

    $scope.gearTableOrder = 'name'
    $scope.setGearTableOrder = (order) ->
        if $scope.gearTableOrder == order
            $scope.gearTableOrder = '-' + order
        else
            $scope.gearTableOrder = order

    $scope.onLoanItemsVisible = true
    $scope.showOnLoanItems = () ->
        $scope.onLoanItemsVisible = true
    $scope.hideOnLoanItems = () ->
        $scope.onLoanItemsVisible = false

    $scope.gearItemVisible = (gearItem) ->
        # default is true...
        visible = true
        # first check if we are showing or hiding onloan items
        if gearItem.status == 'onloan' and $scope.onLoanItemsVisible == false
            visible = false
        # finally return the result
        return visible



    # controller functions
    $scope.refreshGearItems = ->
        $scope.gearItems = GearItems.getList()

    $scope.addGearItem = ->
        # post gear item to server
        GearItems.post($scope.gearItem).then (addedGearItem) ->
            # push the new item into the table
            $scope.gearItems.push addedGearItem
            # $scope.refreshGearItems()
            # if it works, hide the form (Should this go in a separate file?  A directive?)
            $scope.hideGearForm()
            # then delete object from the scope
            $scope.gearItem = {}
        , ->
            console.log 'error posting GearItem'

    $scope.checkOutGearItem = (gearItem) ->
        # update item
        gearItem.status = 'checkedout'
        gearItem.put().then (data) ->
                {}
            , (data) ->
                gearItem.status = 'checkedin'
                console.log 'error: ' + data.data.error

    $scope.checkInGearItem = (gearItem) ->
        # update item
        gearItem.status = 'checkedin'
        gearItem.put().then (data) ->
                {}
            , (data) ->
                gearItem.status = 'checkedout'
                console.log 'error: ' + data.data.error

  ]
