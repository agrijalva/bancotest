var Path_Login = API_Path + '/usuario/';

app.factory( 'loginFactory', function( $http ){
	return {
        login: function( user, pass, tipo ) {
            return $http({
                url: Path_Login + 'login/',
                method: "POST",
                params: {
                    usuario: user,
                    pass: pass,
                    tipousuario: tipo
                },
                headers: {
                    'Content-Type': 'application/json'
                }
            });
        }
    };
});