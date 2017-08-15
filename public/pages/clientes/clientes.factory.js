var Path_Cliente = API_Path + '/cliente/';

app.factory( 'clienteFactory', function( $http ){
	return {
        obtenerClientes: function( idEjecutivo ) {
            return $http({
                url: Path_Cliente + 'obtenerClientes/',
                method: "POST",
                params: {
                    idEjecutivo: idEjecutivo
                },
                headers: {
                    'Content-Type': 'application/json'
                }
            });
        },
        getCatalogo: function( catalogo ) {
            return $http({
                url: Path_Cliente + 'getCatalogo/',
                method: "POST",
                params: {
                    Catalogo: catalogo
                },
                headers: {
                    'Content-Type': 'application/json'
                }
            });
        },
        guardarTarjetahabiente: function( parametros ) {
            return $http({
                url: Path_Cliente + 'guardarTarjetahabiente/',
                method: "POST",
                params: parametros,
                headers: {
                    'Content-Type': 'application/json'
                }
            });
        },
        getCliente: function( noCliente ) {
            return $http({
                url: Path_Cliente + 'getCliente/',
                method: "POST",
                params: {
                    noCliente: noCliente
                },
                headers: {
                    'Content-Type': 'application/json'
                }
            });
        },
        getCuentas: function( idCliente ) {
            return $http({
                url: Path_Cliente + 'getCuentas/',
                method: "POST",
                params: {
                    idCliente: idCliente
                },
                headers: {
                    'Content-Type': 'application/json'
                }
            });
        }
    };
});