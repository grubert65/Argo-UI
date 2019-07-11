use strict;
use warnings;
use Data::Printer;
use Test::More;

use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init( $DEBUG );

use_ok('Argo::Utils', qw(
    runtime_chart_data
) );

ok( my $data = runtime_chart_data( "ycsb-chaos-6tgbn" ), 'runtime_chart_data' );
is( $data->{min}, 0, 'min ok' );
is( $data->{max}, 321018, 'max ok' );

p $data;

done_testing();

