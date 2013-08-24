# gets user status from the server
App.factory 'UserStatus', ['$http', '$timeout', 'Restangular', ($http, $timeout, Restangular) ->
    # the user status object
    this.userStatus = {}

    # keep track of what's observing this
    observerCallbacks = []

    # register observer
    this.registerObserverCallback = (callback) ->
        # add the observer
        observerCallbacks.push(callback)
        resetStatusTimeout()


    # notify observers, called when the status changes
    notifyObservers = () ->
        _.each observerCallbacks, (callback) ->
            callback(this.userStatus)

    updateErrors = 0

    updateUrl = 'status'

    updateCall = () ->
        # return $http.get(updateUrl)
        return Restangular.all(updateUrl).getList()

    this.updateCall = updateCall

    # define our timeout function...
    updateUserStatus = () ->
        updateCall().then (statusData) ->
            # update the variable and notify the observers
            this.userStatus = statusData
            notifyObservers()
            startStatusTimeout()
            updateErrors = 0    # reset error counter
        , (error) ->
            # if there's an error, log it
            console.log 'error:'
            console.log error
            updateErrors += 1
            if updateErrors < 5    # if it fails 5 times, quit.  This should be fixed for prod
                startStatusTimeout()

    # a shortcut for starting the timeout
    startStatusTimeout = () ->
        this.statusTimeout = $timeout updateUserStatus, 10000

    resetStatusTimeout = () ->
        # cancel the current timeout delay and execute the status update again immediately, so we notify any observer right away
        $timeout.cancel this.statusTimeout
        updateUserStatus()

    updateUserStatus()



    # also keep track of other user things, like the unit.  Here we can change it
    this.updateWeightUnit = (weightUnit) ->
        weight_object = {weight_unit: weightUnit}
        Restangular.one(updateUrl).customPUT(weight_object).then () ->
                resetStatusTimeout()
            , (error) ->
                console.log error

    this.updateWeightPrecision = (weightPrecision) ->
        weight_object = {weight_precision: weightPrecision} 
        Restangular.one(updateUrl).customPUT(weight_object).then () ->
                resetStatusTimeout()
            , (error) ->
                console.log error


    return this
]