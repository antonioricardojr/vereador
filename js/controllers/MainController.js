var app = angular.module( 'app' );

app.controller( 'MainController', [ '$scope', 'PropostaService', function ( $scope, PropostaService ) {

    $scope.title = "O que faz o vereador?";
    $scope.subtitle = "Uma visão geral do que ocorre na câmara dos vereadores de Campina Grande-PB";


    $scope.selectedOption = { name: 'Tema' };
    $scope.options = [ { name: 'Tema' }, { name: 'Tipo de Proposta' }, { name: 'Status' } ];

    $scope.propostas = [ ];

    PropostaService.loadPropostas( )
        .then( function ( response ) {
            for ( var i = 0; i < response.data.length; i++ ) {
                $scope.propostas.push( response.data[ i ] );
            }
        } );
    $scope.$watch( 'selectedOption', function ( ) {
        if ( $scope.selectedOption.name === 'Tema' ) {
            console.log( $scope.selectedOption.name );
        } else if ( $scope.selectedOption.name === 'Tipo de Proposta' ) {
            console.log( $scope.selectedOption.name );
        } else if ( $scope.selectedOption.name === 'Status' ) {
            console.log( $scope.selectedOption.name );
        }
    } );
} ] );
