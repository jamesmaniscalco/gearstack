# gets user status from the server
App.factory 'UserStatus', ['$http', '$timeout', ($http, $timeout) ->
    # the user status object
    this.userStatus = {}

    # keep track of what's observing this
    observerCallbacks = []

    # register observer
    this.registerObserverCallback = (callback) ->
        # add the observer
        observerCallbacks.push(callback)
        # cancel the current timeout delay and execute the status update again immediately, so we notify any observer right away
        $timeout.cancel this.statusTimeout
        updateUserStatus()


    # notify observers, called when the status changes
    notifyObservers = () ->
        _.each observerCallbacks, (callback) ->
            callback(this.userStatus)

    # define our timeout function...
    updateUserStatus = () ->
        $http.get('/api/v1/status').success (statusData) ->
            # update the variable and notify the observers
            this.userStatus = statusData
            notifyObservers()
            startStatusTimeout()
        .error (error, status) ->
            # if there's an error, log it
            console.log 'error:'
            console.log error
            console.log status
            startStatusTimeout()

    # a shortcut for starting the timeout
    startStatusTimeout = () ->
        this.statusTimeout = $timeout updateUserStatus, 10000

    updateUserStatus()

    return this
]