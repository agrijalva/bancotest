app.controller("DepositoCtrl", ["$scope", "$location","depositoFactory", function($scope, $location, depositoFactory) {
    $scope.DataUser     = JSON.parse( localStorage.getItem("Data_User") );

    $scope.busqueda = {
        tipo:1,   
        numero:''
    }

    $scope.monto = 0;
    $scope.idEjecutivo = $scope.DataUser.idEjecutivo;
    $scope.idCuenta = 0;

    $scope.buscarCuenta = function() {
		depositoFactory.buscarCuenta( $scope.busqueda.tipo, $scope.busqueda.numero ) .then(function(result){
    		$scope.Resultado = result.data;
            $scope.idCuenta = $scope.Resultado.idCuenta;
        }, function(error){
            console.log("Error", error);
        });    		
    	
    }

    $scope.depositar = function() {
        if( $scope.monto == 0 || $scope.monto == ''){
            swal("Depositos", "No se ha especificado el monto a depositar");
        }
        else{
            depositoFactory.deposito( $scope.monto, $scope.idEjecutivo, $scope.idCuenta ) .then(function(result){
                $scope.ResDeposito = result.data;
                swal("Depositos", $scope.ResDeposito.msg);
                setTimeout( function(){
                    location.reload();                    
                },3000);
                console.log($scope.ResDeposito);
            }, function(error){
                console.log("Error", error);
            }); 
        }
    }
}]);