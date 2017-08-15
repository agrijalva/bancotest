app.controller("LoginCtrl", ["$scope", "$location","loginFactory", function($scope, $location, loginFactory) {
    $scope.user = '';
    $scope.pass = '';

    $scope.submit = function() {
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
	    	loginFactory.login( $scope.user, $scope.pass ) .then(function(result){
	    		var Resultado = result.data;
                console.log( Resultado );
	    		if( Resultado.success ){
                    localStorage.setItem("Data_User", JSON.stringify(Resultado.data[0]));
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