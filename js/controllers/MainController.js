var app = angular.module( 'app' );

app.controller( 'MainController', [ '$scope', 'EmentaService', function ( $scope, EmentaService ) {

    var self = this;

    self.title = "O que faz o vereador?";
    self.subtitle = "Uma visão geral do que ocorre na câmara dos vereadores de Campina Grande-PB";

    self.options = [ { name: 'Tema', value: 1 }, { name: 'Tipo de Proposta', value: 2 }, { name: 'Situação', value: 3 }, { name: 'Relevância', value: 4 } ];

    self.streamChartData = [ ];

    // EmentaService.loadPropostas( )
    //     .then( function ( response ) {
    //         for ( var i = 0; i < response.data.length; i++ ) {
    //             self.propostas.push( response.data[ i ] );
    //         }
    //     } );

    self.ementasPorTema = [ ];
    EmentaService.loadByTema( )
        .then( function ( response ) {
            pushData( response, self.ementasPorTema )
        } )

    self.ementasPorTipo = [ ]
    EmentaService.loadByTipo( )
        .then( function ( response ) {
            pushData( response, self.ementasPorTipo )
        } )

    self.ementasPorSituacao = [ ];
    EmentaService.loadBySituacao( )
        .then( function ( response ) {
            pushData( response, self.ementasPorSituacao )
        } )

    self.ementasPorRelevancia = [ ];
    EmentaService.loadByRelevancia( )
        .then( function ( response ) {
            pushData( response, self.ementasPorRelevancia )
        } )

    function pushData( from, to ) {
        for ( var i = 0; i < from.data.length; i++ ) {
            to.push( from.data[ i ] );
        }
    }

    $scope.selectedOption = { name: 'Tema', value: 1 };
    $scope.$watch( 'selectedOption', function ( ) {
        switch ( $scope.selectedOption.value ) {
        case 1:
            console.log( $scope.selectedOption.name );
            self.streamChartData = self.ementasPorTema
            break;
        case 2:
            console.log( $scope.selectedOption.name );
            self.streamChartData = self.ementasPorTipo
            break;
        case 3:
            console.log( $scope.selectedOption.name );
            self.streamChartData = self.ementasPorSituacao;
            break;
        case 4:
            console.log( $scope.selectedOption.name );
            self.streamChartData = self.ementasPorRelevancia;
            break;
        default:
            console.log( 'default' );
            self.streamChartData = self.ementasPorTema
            break;
        }
    } );
} ] );
