window.App = angular.module('Gearstack', ['ngResource', 'restangular', 'gearstackFilters', 'ngDragDrop'])

App.config ["$routeProvider", ($routeProvider) ->
    $routeProvider.when("/",
      templateUrl: "/assets/angular/templates/gear_table.html"
      controller: "GearController"
      resolve: {
        resolvedGearItems: (GearItems) ->
            GearItems.getList().then(
                    (gearItemList) ->
                        { 
                            success: true,
                            data: gearItemList
                        }
                    ,
                    (error) ->
                        {
                            success: false,
                            data: error
                        }
                    )
        resolvedGearLists: (GearLists) ->
            GearLists.getList().then(
                    (gearLists) ->
                        { 
                            success: true,
                            data: gearLists
                        }
                    ,
                    (error) ->
                        {
                            success: false,
                            data: error
                        }
                    )
      }
    ).otherwise redirectTo: "/"
  ]
  
App.config (RestangularProvider) ->
    RestangularProvider.setBaseUrl("/api/v1")

# configure app to add X-CSRF-Token to headers to make Rails happy
# also delete the X-Requested-With header to help keep API requests from dying
App.config ["$httpProvider", ($httpProvider) ->
    $httpProvider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content')
    delete $httpProvider.defaults.headers.common['X-Requested-With'];
]

# start up the User Status service to make sure that we get the status on load
App.run (UserStatus) ->

