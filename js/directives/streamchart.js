var app = angular.module( 'app' );



app.directive( 'streamchart', function ( ) {
    return {
        'restrict': 'AE',
        'templateUrl': 'graficos_fora/streamchart.html',
        'scope': {
            'isLoading': '=',
            'message': '@'
        }
    }
} );
