window.App = angular.module('Gearstack', ['ngResource', 'restangular', 'gearstackFilters'])

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
      }
    ).otherwise redirectTo: "/"
  ]
  
App.config (RestangularProvider) ->
    RestangularProvider.setBaseUrl("/api/v1")

# configure app to add X-CSRF-Token to headers to make Rails happy
App.config ["$httpProvider", ($httpProvider) ->
    $httpProvider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content')
]
