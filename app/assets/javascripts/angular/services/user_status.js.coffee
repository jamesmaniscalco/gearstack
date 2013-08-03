# gets user status from the server
App.factory 'UserStatus', ['Restangular', (Restangular) ->
    UserStatus = Restangular.one 'status'
    return UserStatus
]