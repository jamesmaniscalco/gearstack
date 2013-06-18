window.App = angular.module('Gearstack', ['ngResource'])
  .config ["$routeProvider", ($routeProvider) ->
    $routeProvider.when("/",
      templateUrl: "/assets/angular/templates/gear_table.html"
      controller: "GearController"
    ).otherwise redirectTo: "/"
  ]
