# gets user status from the server
App.factory 'UserStatus', ['$http', ($http) ->
    # poll the server every ten seconds or so.
    userStatus = {}
]