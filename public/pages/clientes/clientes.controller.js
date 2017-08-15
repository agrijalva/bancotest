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

    $scope.idTipoCuenta  = 0;
    $scope.idTipoTarjeta = 0;


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

    $scope.InitDetalle = function(){
        clienteFactory.getCliente( $scope.GET.noCliente ).then(function(result){
            $scope.Detalle = result.data[0];
            console.log( $scope.Detalle );

            clienteFactory.getCuentas( $scope.Detalle.idCliente ).then(function(result){
                $scope.Cuentas = result.data;
                console.log( result );
            });
        }, function(error){
            console.log("Error", error);
        });

        $scope.InitNuevo();
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
        $scope.TarjetaHabiente.idEjecutivo = $scope.DataUser.idEjecutivo;

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

    $scope.guardarTarjeta = function(){
        var parametros = {
            idTipoCuenta: $scope.idTipoCuenta,
            idTipoTarjeta: $scope.idTipoTarjeta,
            idEjecutivo: $scope.DataUser.idEjecutivo,
            noCliente: $scope.GET.noCliente,
            noTarjeta: '291' + Date.now(),
            idCliente: $scope.Detalle.idCliente
        }

        clienteFactory.guardarTarjeta( parametros ).then(function(result){
            $scope.ResTarjeta = result.data;
            swal("Banco de Prueba",$scope.ResTarjeta.msg);
            if( $scope.ResTarjeta.success ){
                // $location.path("/admin/clientes");
                $scope.InitDetalle();
            }
            console.log( result );
        }, function(error){
            console.log("Error", error);
        });
    }

}]);