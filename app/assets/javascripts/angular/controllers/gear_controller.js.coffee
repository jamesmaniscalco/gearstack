# App.controller 'GearController', ['$scope', 'Restangular', ($scope, Restangular) ->
App.controller 'GearController', ['$scope', '$q', '$http', '$timeout', 'Restangular', 'resolvedGearItems', 'resolvedGearLists', 'resolvedUserStatus', 'GearItems', 'GearLists', 'UserStatus', ($scope, $q, $http, $timeout, Restangular, resolvedGearItems, resolvedGearLists, resolvedUserStatus, GearItems, GearLists, UserStatus) ->
    # pull in data from the resolve in the $routeProvider
    if resolvedGearItems.success and resolvedGearLists.success
        $scope.gearItems = resolvedGearItems.data
        $scope.gearLists = resolvedGearLists.data
    else
        console.log 'error'
        console.log resolvedGearItems.data

    # keep track of things in User Status
    $scope.userStatus = resolvedUserStatus
    updateUserStatus = (userStatusData) ->
        $scope.userStatus = userStatusData

    # register the callback with User Status to keep it updated
    UserStatus.registerObserverCallback(updateUserStatus)



    ##############
    # GEAR ITEMS #
    ##############



    # DOM manipulation
    $scope.addGearFormVisible = false

    $scope.showAddGearForm = ->
        $scope.addGearFormVisible = true
        # and just in case they get through the disable,
        $scope.cancelEditGearItem()

    $scope.hideAddGearForm = ->
        $scope.addGearFormVisible = false

    $scope.okToAddGearItem = () ->
        if not $scope.gearItemBeingEditedId # if we're editing something, set it to false
            true
        else
            false

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
        {title: 'name', class: 'span3'},
        {title: 'description', class: 'span2'},
        {title: 'location', class: 'span2'},
        {title: 'weight', class: 'span1'},
        {title: 'status', class: 'span2'}
    ]

    # editing things
    #$scope.editingGearItemEnabled = false
    $scope.gearItemBeingEditedId = null
    $scope.gearItemBeingEdited = null

    # are we editing a given item?
    $scope.editingThisGearItem = (gearItem) ->
        #if $scope.gearItemBeingEdited == gearItem.id
        if $scope.gearItemBeingEditedId == gearItem.id
            true
        else
            false

    # set it to edit!
    $scope.editGearItem = (gearItem) ->
        # $scope.gearItemBeingEdited = gearItem.id
        $scope.gearItemBeingEdited = Restangular.copy gearItem
        $scope.gearItemBeingEditedId = $scope.gearItemBeingEdited.id
        $scope.hideAddGearForm()

    $scope.resetEditGearItem = ->
        $scope.gearItemBeingEdited = null
        $scope.gearItemBeingEditedId = null

    $scope.cancelEditGearItem = ->
        # check if there's actually an edit to cancel...
        if $scope.gearItemBeingEditedId
            $scope.gearItems = _.without $scope.gearItems, _.findWhere $scope.gearItems, {id: $scope.gearItemBeingEditedId}     # this is pretty ugly, but it works!
            $scope.gearItems.push $scope.gearItemBeingEdited    # restore it from the copy we made
        # then do this anyway
        $scope.resetEditGearItem()

    # check if it's OK to do certain things
    $scope.okToEditGearItem = (gearItem) -> # disable if something is being edited already
        if (not $scope.gearItemBeingEditedId) and ($scope.gearItemBeingEditedId != gearItem.id and $scope.itemIsPossessedByCurrentUser(gearItem) and $scope.itemBelongsToCurrentUser(gearItem))
            true
        else
            false

    $scope.okToDeleteGearItem = (gearItem) -> # disable if something is being edited
        if (not $scope.gearItemBeingEditedId) and ($scope.itemIsPossessedByCurrentUser(gearItem) and $scope.itemBelongsToCurrentUser(gearItem))
            true
        else
            false

    $scope.okToCheckOutItem = (gearItem) ->
        if $scope.itemIsCheckedIn(gearItem) and not $scope.gearItemBeingEditedId
            true
        else
            false

    $scope.okToCheckInItem = (gearItem) ->
        if $scope.itemIsCheckedOut(gearItem) and not $scope.gearItemBeingEditedId
            true
        else
            false

    # searching within gear table: just run the sort on name, description, location, and weight.
    $scope.gearItemsSearchQuery = ""
    $scope.gearItemsSearch = (gearItem) ->
        # do it with regex!
        re = RegExp $scope.gearItemsSearchQuery, 'i'
        return (not $scope.gearItemsSearchQuery) or re.test(gearItem.name) or re.test(gearItem.description) or re.test(gearItem.location) or re.test(gearItem.weight)




    # controller functions
    $scope.refreshGearItems = ->
        $scope.gearItems = GearItems.getList()
        console.log $scope.gearItems

    $scope.addGearItem = ->
        # check if a gear list is selected
        if $scope.selectedListId
            $scope.gearItem.gear_lists = [{id: $scope.selectedListId}]
        # post gear item to server
        GearItems.post($scope.gearItem).then (addedGearItem) ->
            # push the new item into the table
            $scope.gearItems.push addedGearItem
            # if it works, hide the form (Should this go in a separate file?  A directive?)
            $scope.hideAddGearForm()
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
            gearItem.remove().then ->
                    # if delete was successful on server, remove from the scope
                    $scope.gearItems = _.without $scope.gearItems, gearItem
                , ->
                    # if it wasn't, do an alert (TODO: make this nicer later!)
                    alert gearItem.name + ' not deleted (server communication error)'

    $scope.updateGearItem = (gearItem) ->
        # remember we have an unedited copy in $scope.gearItemBeingEdited
        gearItem.put().then (data) ->
                # if successful, we can just set editing mode off
                $scope.resetEditGearItem()  # this just sets things to null and keeps the changes.
            , (data) ->
                # if unsuccessful, set it back to the copy, alert the user, and set the copy to null
                gearItem = Restangular.copy $scope.gearItemBeingEdited
                alert gearItem.name + ' not updated (server communication error)'
                $scope.cancelEditGearItem() # this reverts any changes




    ##############
    # GEAR LISTS #
    ##############

    $scope.selectedListId = null

    $scope.deselectGearList = ->
        $scope.selectedListId = null

    $scope.selectGearList = (gearList) ->
        $scope.selectedListId = gearList.id

    $scope.gearListSelectedClass = (gearList) ->
        if $scope.selectedListId == gearList.id
            return 'selected-list'
        else
            return ''

    $scope.noGearListSelectedClass = ->
        if not $scope.selectedListId
            return 'selected-list'
        else
            return ''


    # creating, editing, and deleting gear lists
    $scope.addingGearList = false

    $scope.showAddGearListForm = ->
        $scope.addingGearList = true

    $scope.hideAddGearListForm = ->
        $scope.addingGearList = false
        $scope.newGearList = {}

    # editing:
    $scope.gearListBeingEditedId = null
    $scope.gearListBeingEdited = null

    # are we editing a given list?
    $scope.editingThisGearList = (gearList) ->
        if $scope.gearListBeingEditedId == gearList.id
            true
        else
            false

    # set it to edit!
    $scope.editGearList = (gearList) ->
        $scope.gearListBeingEdited = Restangular.copy gearList
        $scope.gearListBeingEditedId = $scope.gearListBeingEdited.id
        $scope.hideAddGearListForm()

    $scope.resetEditGearList = ->
        $scope.gearListBeingEdited = null
        $scope.gearListBeingEditedId = null

    $scope.cancelEditGearList = ->
        # check if there's actually an edit to cancel...
        if $scope.gearListBeingEditedId
            $scope.gearLists = _.without $scope.gearLists, _.findWhere $scope.gearLists, {id: $scope.gearListBeingEditedId}     # this is pretty ugly, but it works!
            $scope.gearLists.push $scope.gearListBeingEdited    # restore it from the copy we made
        # then do this anyway
        $scope.resetEditGearList()



    $scope.okToEditGearList = (gearList) -> # disable if something is being edited already
        if (not $scope.gearListBeingEditedId) and ($scope.gearListBeingEditedId != gearList.id)
            true
        else
            false





    $scope.addGearList = ->
        GearLists.post($scope.newGearList).then (addedGearList) ->
            $scope.gearLists.push addedGearList
            $scope.hideAddGearListForm()
        , ->
            console.log 'error creating gear list'

    $scope.okToDeleteGearList = (gearList) ->
        if not $scope.gearListBeingEditedId
            return true
        else
            return false

    $scope.removeGearList = (gearList) ->
        confirmText =  'Are you sure you want to delete "' + gearList.name + '" from your library?'
        deleteGearList = confirm confirmText

        if deleteGearList
            gearList.remove().then ->
                    # if delete was successful on server, remove from the scope
                    $scope.gearLists = _.without $scope.gearLists, gearList
                    # then adjust each gear item so that the deleted gear list is taken out
                    _.each $scope.gearItems, (gearItem) ->
                        gearItem.gear_lists = _.reject gearItem.gear_lists, (gearItemGearList) ->
                            return (gearItemGearList.id == gearList.id)
                    $scope.deselectGearList()   # because clicking the button probably sent an ng-click to select a list

                , ->
                    # if it wasn't, do an alert (TODO: make this nicer later!)
                    alert gearList.name + ' not deleted (server communication error)'

    $scope.updateGearList = (gearList) ->
        # remember we have an unedited copy in $scope.gearItemBeingEdited
        gearList.put().then (data) ->
                # if successful, we can just set editing mode off
                $scope.resetEditGearList()  # this just sets things to null and keeps the changes.
            , (data) ->
                # if unsuccessful, set it back to the copy, alert the user, and set the copy to null
                gearList = Restangular.copy $scope.gearListBeingEdited
                alert gearList.name + ' not updated (server communication error)'
                $scope.cancelEditGearList() # this reverts any changes



    #######################
    # GEAR ITEMS IN LISTS #
    #######################

    $scope.removableGearLists = (gearItem) ->
        removableGearLists = []
        # run through each gear list associated with the item,
        for list in gearItem.gear_lists
            # and add that to the list.  use concat because .where gives an array.
            removableGearLists.push _.findWhere $scope.gearLists, {id: list.id}
        return removableGearLists

    $scope.addableGearLists = (gearItem) ->
        # start with the removable lists,
        removableGearLists = $scope.removableGearLists(gearItem)
        # and take the other ones.
        addableGearLists = _.difference $scope.gearLists, removableGearLists
        return addableGearLists

    # this is pretty much the same as okToDeleteGearItem
    $scope.okToAddOrRemoveGearLists = (gearItem) -> # disable if something is being edited
        if (not $scope.gearItemBeingEditedId) and ($scope.itemIsPossessedByCurrentUser(gearItem) and $scope.itemBelongsToCurrentUser(gearItem))
            true
        else
            false

    $scope.gearItemCopy = null

    $scope.addToGearList = (gearItem, gearList) ->
        # first add the list
        $scope.gearItemCopy = Restangular.copy gearItem    # save a copy
        gearItem.gear_lists.push {id: gearList.id}
        # then save to the server
        gearItem.put().then (data) ->
                # if this works, then cool!
                {}  # do nothing
            , (data) ->
                # if unsuccessful, set it back to the copy, alert the user, and set the copy to null
                gearItem.gear_lists = $scope.gearItemCopy.gear_lists
                $scope.gearItemCopy = null
                alert gearItem.name + ' not updated (server communication error)'

    $scope.removeFromGearList = (gearItem, gearList) ->
        # first add the list
        $scope.gearItemCopy = Restangular.copy gearItem    # save a copy
        gearItem.gear_lists = _.reject gearItem.gear_lists, (gearItemGearList) ->
                return (gearItemGearList.id == gearList.id)
        # then save to the server
        gearItem.put().then (data) ->
                # if this works, then cool!
                {}  # do nothing
            , (data) ->
                # if unsuccessful, set it back to the copy, alert the user, and set the copy to null
                gearItem.gear_lists = $scope.gearItemCopy.gear_lists
                $scope.gearItemCopy = null
                alert gearItem.name + ' not updated (server communication error)'

  ]
