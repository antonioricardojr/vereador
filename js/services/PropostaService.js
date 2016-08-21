var app = angular.module( 'app' );


app.service( 'PropostaService', [ '$http', 'appconfig', function ( $http, appconfig ) {

    var self = this;

    self.url = appconfig.apiUrl;
    console.log( self.url );
    self.loadPropostas = function ( ) {
        return $http.get( self.url );
    }
} ] );
