angular.module("yapp").controller("LoginCtrl", ["$scope", "$location", function($scope, t) {
    $scope.submit = function() {
        console.log( API_Path );
        t.path("/dashboard/agentes");
    }
}]);