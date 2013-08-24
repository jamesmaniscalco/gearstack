App.controller 'UserSettingsController', ['$scope', '$q', 'UserStatus', 'resolvedUserStatus', ($scope, $q, UserStatus, resolvedUserStatus) ->
    # get the user status from the resolved data
    if resolvedUserStatus.success
        $scope.userStatus = resolvedUserStatus.data
    else
        console.log 'error'
        console.log resolvedUserStatus.success

    # keep track of things in User Status
    updateUserStatus = (userStatusData) ->
        $scope.userStatus = userStatusData

    # register the callback with User Status to keep it updated
    UserStatus.registerObserverCallback(updateUserStatus)

    $scope.saveUserSettings = () ->
        UserStatus.updateWeightUnit $scope.selectedWeightUnit.unit
        UserStatus.updateWeightPrecision $scope.selectedWeightPrecision.precision



    $scope.weightUnitOptions = [
        {unit: 'gram'},
        {unit: 'kilogram'},
        {unit: 'pound'},
        {unit: 'ounce'}
    ]

    $scope.weightPrecisionOptions = [
        {precision: 0},
        {precision: 1},
        {precision: 2},
        {precision: 3}
    ]

    resetSettings = () ->
        $scope.selectedWeightUnit = _.findWhere $scope.weightUnitOptions, {unit: $scope.userStatus.weight_unit}
        $scope.selectedWeightPrecision = _.findWhere $scope.weightPrecisionOptions, {precision: $scope.userStatus.weight_precision}

    resetSettings()
]