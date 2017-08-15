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
                	// 'Authorization': Authorization,
                    'Content-Type': 'application/json'
                }
            });
        }
    };
});