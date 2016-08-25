var app = angular.module( 'app' );


app.service( 'EmentaService', [ '$http', 'appconfig', function ( $http, appconfig ) {

    var self = this;

    self.url = appconfig.apiUrl;
    console.log( self.url );

    self.loadByTema = function ( ) {
        return $http.get( self.url + '/tema' );
    }

    self.loadByTipo = function ( ) {
        return $http.get( self.url + '/tipo' );
    }

    self.loadBySituacao = function ( ) {
        return $http.get( self.url + '/situacao' );
    }

    self.loadByRelevancia = function ( ) {
        return $http.get( self.url + '/relevancia' );
    }

} ] );
