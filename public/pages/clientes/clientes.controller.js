app.controller("ClientesCtrl", ["$scope", "$location","clienteFactory","filterFilter", function($scope, $location, clienteFactory, filterFilter) {
    $scope.DataUser     = JSON.parse( localStorage.getItem("Data_User") );
    $scope.GET          = $location.$$search;

    $scope.Clientes        = [];
    $scope.tipoCuenta      = [];
    $scope.tipoTarjeta     = [];

    $scope.TarjetaHabiente = {
        noCliente: '',
        cli_nombre: '',
        cli_apellidos: '',
        cli_rfc: '',
        cli_email: '',
        cli_telefono: '',
        cli_celular: '',
        idEstatusCliente: 1,
        idEjecutivo: '',

        idTipoCuenta: '',
        noTarjeta: '',
        idTipoTarjeta: ''
    };


    $scope.Init = function(){
        $scope.obtenerClientes();
    } 

    $scope.InitNuevo = function(){
        clienteFactory.getCatalogo( 'cuenta' ).then(function(result){
            $scope.tipoCuenta = result.data;
        });

        clienteFactory.getCatalogo( 'tarjeta' ).then(function(result){
            $scope.tipoTarjeta = result.data;
        });
    }    

    $scope.obtenerClientes = function(  ){
        clienteFactory.obtenerClientes( $scope.DataUser.idEjecutivo ).then(function(result){
            $scope.Clientes = result.data;
        }, function(error){
            console.log("Error", error);
        });
    }

    $scope.SaveCliente = function(){
        $scope.TarjetaHabiente.noCliente   = Date.now();
        $scope.TarjetaHabiente.noTarjeta   = '291' + Date.now();
        $scope.TarjetaHabiente.idEjecutivo = $scope.DataUser.idEjecutivo

        clienteFactory.guardarTarjetahabiente( $scope.TarjetaHabiente ).then(function(result){
            $scope.ResCliente = result.data;
            swal("Banco de Prueba",$scope.ResCliente.msg);
            if( $scope.ResCliente.success ){
                $location.path("/admin/clientes");
            }
            console.log( result );
        }, function(error){
            console.log("Error", error);
        });
    }
}]);