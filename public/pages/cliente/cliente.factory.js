var Path_Cliente = API_Path + '/cliente/';

app.factory( 'panelFactory', function( $http ){
	return {
        buscarCuenta: function( tipo, numero ) {
            return $http({
                url: Path_Cliente + 'buscarCuenta/',
                method: "POST",
                params: {
                    tipo: tipo,
                    numero: numero
                },
                headers: {
                    'Content-Type': 'application/json'
                }
            });
        },
        deposito: function( mov_monto, idEjecutivo, idCuenta ) {
            return $http({
                url: Path_Cliente + 'deposito/',
                method: "POST",
                params: {
                    mov_monto: mov_monto,
                    idEjecutivo: idEjecutivo,
                    idCuenta: idCuenta
                },
                headers: {
                    'Content-Type': 'application/json'
                }
            });
        }
    };
});