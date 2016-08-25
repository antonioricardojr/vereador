var app = angular.module( 'app' );


app.directive( 'radialchart', [ function ( ) {

    var link = function ( scope, element ) {
        var width = 960,
            height = 600,
            margin = 40,
            maxRadius = ( height / 2 ) - margin;

        var ticks = [ 0, 100, 200, 300, 400, 500, 600 ];
        console.log( d3 );

        var x = d3.scale.linear( )
            .domain( [ 0, 500 ] )
            .range( [ 120, maxRadius ] );

        var xAxis = d3.svg.axis( )
            .scale( x )
            .orient( "left" )
            .tickValues( ticks )
            .tickFormat( function ( d ) {
                return d;
            } );

        var r = d3.scale.linear( )
            .domain( [ 0, 200 ] )
            .range( [ 0, maxRadius / 4 ] );

        var color = d3.scale.linear( )
            .domain( ticks )
            .range( [ "#00375a", "#1b6491", "#52b7e7", "#96d88c", "#fbd65f", "#e46c56", "#9e3b2c" ] );

        var svg = d3.select( element[ 0 ] )
            .append( "svg" )
            .attr( {
                'version': '1.1',
                'viewBox': '0 0 ' + width + ' ' + height,
                'width': '100%',
                'class': 'streamchart'
            } )
            .append( "g" )
            .attr( "transform", "translate(" + width / 2 + "," + height / 2 + ")" );

        d3.json( "graficos_fora/circulo/testeCirculo.json", function ( error, data ) {

            data.forEach( function ( d ) {
                d[ "min" ] = +d[ "min" ];
                d[ "max" ] = +d[ "max" ];
                d[ "media" ] = +d[ "media" ];
                d[ "aprovados" ] = ( d[ "aprovados" ] === "T" ) ? 0 : +d[ "aprovados" ];
            } );

            var arc = d3.svg.arc( )
                .startAngle( function ( d ) {
                    return 0;
                } )
                .endAngle( function ( d ) {
                    return ( ( 2 * Math.PI ) / ( data.length ) );
                } )
                .innerRadius( function ( d ) {
                    return x( d[ "min" ] );
                } )
                .outerRadius( function ( d ) {
                    return x( d[ "max" ] );
                } );

            var tickCircles = svg.append( "g" )
                .attr( "class", "ticksCircle" );

            tickCircles.selectAll( "circle" )
                .data( ticks )
                .enter( )
                .append( "circle" )
                .attr( "r", function ( d ) {
                    return x( d );
                } )
                .style( "fill", "none" )
                .style( "stroke", "#d6d6d6" )
                .style( "stroke-width", function ( d, i ) {
                    return ( ( i & 1 ) === 0 ) ? 1 : 0.25;
                } );

            var propostas = svg.selectAll( ".proposta" )
                .data( data )
                .enter( )
                .append( "g" )
                .attr( "class", "proposta" )
                .attr( "transform", function ( d, i ) {
                    return "rotate(" + ( i * 360 / data.length ) + ")";
                } );

            propostas.append( "path" )
                .style( "stroke", "white" )
                .style( "stroke-width", 1.2 )
                .style( "fill", function ( d ) {
                    return color( d[ "media" ] );
                } )
                .attr( "d", arc );

            var precipitations = svg.selectAll( ".precipitation" )
                .data( data )
                .enter( )
                .append( "g" )
                .attr( "class", "precipitation" )
                .attr( "transform", function ( d, i ) {
                    return "rotate(" + ( i * 360 / data.length ) + ")";
                } );

            precipitations.append( "circle" )
                .attr( "cx", 8 )
                .attr( "cy", function ( d ) {
                    return -x( d[ "media" ] );
                } )
                .attr( "r", function ( d ) {
                    return 5;
                } )
                .style( "opacity", .15 )
                .style( "fill", "#00000" );

            var legend = svg.append( "g" )
                .attr( "class", "legend" );

            legend.append( "text" )
                .attr( "dy", ".35em" )
                .style( "font-size", 40 )
                .style( "fill", "#454545" )
                .style( "font-family", "monospace" )
                .style( "text-anchor", "middle" )
                .text( "A Câmara" );

            svg.append( "g" )
                .attr( "class", "x axis" )
                .call( xAxis )
                .selectAll( "text" )
                .style( "fill", "#454545" )
                .style( "text-anchor", "middle" );
        } );

        d3.select( self.frameElement )
            .style( "height", height + "px" );
    }
    return {
        'template': '',
        'restrict': 'AE',
        'scope': {
            'isLoading': '=',
            'message': '@'
        },
        'link': link
    }
} ] );
