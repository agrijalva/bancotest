app.controller("ClienteCtrl", ["$scope", "$location", "clienteFactory", function($scope, $location, clienteFactory) {
    $scope.DataUser     = JSON.parse( localStorage.getItem("Data_User") );

    $scope.InitDetalle = function(){
        clienteFactory.getCliente( $scope.DataUser.noCliente ).then(function(result){
            $scope.Detalle = result.data[0];
            console.log( $scope.Detalle );

            clienteFactory.getCuentas( $scope.Detalle.idCliente ).then(function(result){
                $scope.Cuentas = result.data;
                console.log( result );
            });
        }, function(error){
            console.log("Error", error);
        });
    }
}]);