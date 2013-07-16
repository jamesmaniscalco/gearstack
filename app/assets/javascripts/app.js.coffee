window.App = angular.module('Gearstack', ['ngResource', 'restangular'])
  .config(["$routeProvider", ($routeProvider) ->
    $routeProvider.when("/",
      templateUrl: "/assets/angular/templates/gear_table.html"
      controller: "GearController"
    ).otherwise redirectTo: "/"
  ])
  .config (RestangularProvider) ->
    RestangularProvider.setBaseUrl("/api/v1")


window.App.config ["$httpProvider", ($httpProvider) ->
    $httpProvider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content')
]