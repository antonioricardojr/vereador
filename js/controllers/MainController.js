var app = angular.module( 'app' );

app.controller( 'MainController', [ '$scope', 'PropostaService', function ( $scope, PropostaService ) {

    $scope.title = "O que faz o vereador?";
    $scope.subtitle = "Uma visão geral do que ocorre na câmara dos vereadores de Campina Grande-PB";

    $scope.propostas = PropostaService.loadPropostas( );


} ] );
