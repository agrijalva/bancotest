app.controller("AdminCtrl", ["$scope", "$location", function($scope, $location) {
	$scope.TipoUser = localStorage.getItem('TipoUser');
}]);