use strict;
use warnings;
use Data::Printer;
use Test::More;

use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init( $DEBUG );

use_ok('Argo::Utils', qw(
    runtime_chart_data
    throughput_chart_data
    operations_chart_data
) );

ok( my $data = runtime_chart_data( "ycsb-chaos-6tgbn" ), 'runtime_chart_data' );
is( $data->{min}, 0, 'min ok' );
is( $data->{max}, 321018, 'max ok' );
p $data;

ok( $data = throughput_chart_data( "ycsb-chaos-6tgbn" ), 'throughput_chart_data' );
is( $data->{min}, 0, 'min ok' );
is( $data->{max}, 409, 'max ok' );
p $data;

ok( $data = operations_chart_data( "ycsb-chaos-6tgbn" ), 'operations_chart_data' );
is( $data->{min}, 0, 'min ok' );
is( $data->{max}, 10, 'max ok' );
p $data;

done_testing();

