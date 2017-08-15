app.controller("ClientesCtrl", ["$scope", "$location","clienteFactory","filterFilter", function($scope, $location, clienteFactory, filterFilter) {
    $scope.DataUser     = JSON.parse( localStorage.getItem("Data_User") );
    $scope.GET          = $location.$$search;

    $scope.Init = function(){
        $scope.obtenerClientes();
    }    

    $scope.obtenerClientes = function(  ){
        clienteFactory.obtenerClientes( $scope.DataUser.idEjecutivo ).then(function(result){
            $scope.Clientes = result.data;
            console.log( $scope.Clientes );
        }, function(error){
            console.log("Error", error);
        });
    }
}]);