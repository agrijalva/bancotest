app.controller("LoginCtrl", ["$scope", "$location","loginFactory", function($scope, $location, loginFactory) {
    $scope.user = '';
    $scope.pass = '';

    $scope.loginEjecutivo = function() {
    	if( $scope.user == '' && $scope.pass == '' ){
    		alert('Asegurate de proporcionar tus credenciales.');
    	}
    	else if( $scope.user == '' ){
    		alert('Proporciona tu usuario para poder acceder al sistema');
    	}
    	else if( $scope.pass == '' ){
    		alert('Proporciona tu contrasema para poder acceder al sistema');
    	}
    	else{
	    	loginFactory.login( $scope.user, $scope.pass, 2 ) .then(function(result){
	    		var Resultado = result.data;
	    		if( Resultado.success ){
                    localStorage.setItem("Data_User", JSON.stringify(Resultado.data[0]));
                    localStorage.setItem("TipoUser", 2);
                    $location.path("/admin/clientes");
	    		}
	    		else{
	    			alert( Resultado.msg );
	    		}
	        }, function(error){
	            console.log("Error", error);
	        });    		
    	}
    }

    $scope.loginCajero = function() {
        if( $scope.user == '' && $scope.pass == '' ){
            alert('Asegurate de proporcionar tus credenciales.');
        }
        else if( $scope.user == '' ){
            alert('Proporciona tu usuario para poder acceder al sistema');
        }
        else if( $scope.pass == '' ){
            alert('Proporciona tu contrasema para poder acceder al sistema');
        }
        else{
            loginFactory.login( $scope.user, $scope.pass, 3 ) .then(function(result){
                var Resultado = result.data;
                if( Resultado.success ){
                    localStorage.setItem("Data_User", JSON.stringify(Resultado.data[0]));
                    localStorage.setItem("TipoUser", 3);
                    $location.path("/admin/depositos");
                }
                else{
                    alert( Resultado.msg );
                }
            }, function(error){
                console.log("Error", error);
            });         
        }
    }

    $scope.loginCliente = function() {
        if( $scope.user == '' && $scope.pass == '' ){
            alert('Asegurate de proporcionar tus credenciales.');
        }
        else if( $scope.user == '' ){
            alert('Proporciona tu usuario para poder acceder al sistema');
        }
        else if( $scope.pass == '' ){
            alert('Proporciona tu contrasema para poder acceder al sistema');
        }
        else{
            loginFactory.login( $scope.user, $scope.pass, 4 ) .then(function(result){
                var Resultado = result.data;
                if( Resultado.success ){
                    localStorage.setItem("Data_User", JSON.stringify(Resultado.data[0]));
                    localStorage.setItem("TipoUser", 4);
                    $location.path("/admin/clientes");
                }
                else{
                    alert( Resultado.msg );
                }
            }, function(error){
                console.log("Error", error);
            });         
        }
    }
}]);