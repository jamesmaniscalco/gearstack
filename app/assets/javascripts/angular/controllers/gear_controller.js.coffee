# App.controller 'GearController', ['$scope', 'Restangular', ($scope, Restangular) ->
App.controller 'GearController', ['$scope', '$q', '$http', '$timeout', 'resolvedGearItems', 'GearItems', 'UserStatus', ($scope, $q, $http, $timeout, resolvedGearItems, GearItems, UserStatus) ->
    # pull in data from the resolve in the $routeProvider
    if resolvedGearItems.status = true
        $scope.gearItems = resolvedGearItems.data
    else
        console.log 'error'
        console.log resolvedGearItems.data

    # keep track of things in User Status
    updateUserStatus = (userStatusData) ->
        $scope.userStatus = userStatusData

    # register the callback with User Status to keep it updated
    UserStatus.registerObserverCallback(updateUserStatus)

    # DOM manipulation
    $scope.gearFormVisible = false

    $scope.showGearForm = ->
        $scope.gearFormVisible = true

    $scope.hideGearForm = ->
        $scope.gearFormVisible = false

    $scope.itemBelongsToCurrentUser = (gearItem) ->
        if $scope.userStatus and (gearItem.owner_id == $scope.userStatus.current_user_id)  # ugly-ish hack to avoid error messages made during the render, because we don't immediately have the user status.  This should probably get fixed with the user status, so we make sure we get that first.
            true
        else
            false

    $scope.itemIsPossessedByCurrentUser = (gearItem) ->
        if $scope.userStatus and (gearItem.possessor_id == $scope.userStatus.current_user_id)
            true
        else
            false

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

    $scope.showGearTableSortIcon = (columnName, order) ->
        visible = false
        if order == "reverse"
            if $scope.gearTableOrder == '-' + columnName
                visible = true
        else
            if $scope.gearTableOrder == columnName
                visible = true
        return visible

    #can we see the items that are on loan?
    $scope.onLoanItemsVisible = true
    #some methods to toggle that
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

    #dynamically load table headers
    $scope.gearTableHeadings = [
        'name',
        'description',
        'location',
        'weight',
        'status'
    ]



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

    $scope.removeGearItem = (gearItem) ->
        confirmText =  'Are you sure you want to delete "' + gearItem.name + '" from your library?'
        deleteGearItem = confirm confirmText

        if deleteGearItem
            gearItem.remove().then () ->
                    # if delete was successful on server, remove from the scope
                    $scope.gearItems = _.without $scope.gearItems, gearItem
                , () ->
                    # if it wasn't, do an alert (TODO: make this nicer later!)
                    alert gearItem.name + ' not deleted (server communication error)'

  ]
