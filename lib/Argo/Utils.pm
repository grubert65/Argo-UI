package Argo::Utils;
use strict;
use warnings;
use Argo;
use YCSB::Metrics;
use Log::Log4perl;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
    runtime_chart_data
    throughput_chart_data
    operations_chart_data
    read_latencies_chart_data
    insert_latencies_chart_data
    update_latencies_chart_data
    get_log
);

our $log = Log::Log4perl->get_logger(__PACKAGE__);

our $argo_client = Argo->new(port => 8080);

sub get_log {
    my $id = shift;

    my $log = $argo_client->workflow_log( $id );
    my @log = split(/\n/, $log);
    shift @log;
    my $trimmed = join("\n", @log);
    return $trimmed;
}

sub _metrics {
    my $id = shift;

    my $metrics = {};
    my $steps = $argo_client->workflows_as_tree();
    my $pods = $argo_client->get_pods_of_workflow($steps, $id );
    my @pod_array = @$pods;
    foreach my $id ( @$pods ) {
        if ( $id =~ /^ycsb/ ) {
            my $y = YCSB::Metrics->new();
            my $log = get_log( $id );
            $y->load_metrics( $log );
            if ( scalar keys %{$y->{metrics}} ) {
                $metrics->{$id} = $y->{metrics};
            } else {
                # this to delete pods with no metrics...
                my @indicesToKeep = grep { $pod_array[$_] ne $id } 0..$#pod_array;
                @pod_array = @pod_array[@indicesToKeep];
            }
        }
    }
    return ( $metrics, @pod_array );
}

sub runtime_chart_data {
    my $id = shift;

    my ($metrics, @pod_array) = _metrics( $id );
    my ($graph_metrics, $min, $max) = runtime_metrics( $metrics ); 
    return { 
        metrics         => $graph_metrics, 
        min             => $min, 
        max             => $max,
        unit_interval   => int(($max - $min)/10),
        series          => get_series( @pod_array )
    };
}

sub throughput_chart_data {
    my $id = shift;

    $log->debug("throughput_chart_data");
    my ($metrics, @pod_array) = _metrics( $id );
    my ($graph_metrics, $min, $max) = throughput_metrics( $metrics ); 
    return { 
        metrics         => $graph_metrics, 
        min             => $min, 
        max             => $max,
        unit_interval   => int(($max - $min)/10),
        series          => get_series( @pod_array )
    };
}

sub operations_chart_data {
    my $id = shift;

    $log->debug("operations_chart_data");
    my ($metrics, @pod_array) = _metrics( $id );
    my ($graph_metrics, $min, $max, $series) = operations_metrics( $metrics ); 
    return { 
        metrics         => $graph_metrics, 
        min             => $min, 
        max             => $max,
        unit_interval   => int(($max - $min)/10),
        series          => $series
    };
}

sub read_latencies_chart_data {
    my $id = shift;

    $log->debug("read_latencies_chart_data");
    my ($metrics, @pod_array) = _metrics( $id );
    my ($graph_metrics, $min, $max) = read_latencies_metrics( $metrics ); 
    return { 
        metrics         => $graph_metrics, 
        min             => $min, 
        max             => $max,
        unit_interval   => int(($max - $min)/10),
        series          => get_series( @pod_array )
    };
}

sub insert_latencies_chart_data {
    my $id = shift;

    $log->debug("read_latencies_chart_data");
    my ($metrics, @pod_array) = _metrics( $id );
    my ($graph_metrics, $min, $max) = insert_latencies_metrics( $metrics ); 
    return { 
        metrics         => $graph_metrics, 
        min             => $min, 
        max             => $max,
        unit_interval   => int(($max - $min)/10),
        series          => get_series( @pod_array )
    };
}

sub update_latencies_chart_data {
    my $id = shift;

    $log->debug("update_latencies_chart_data");
    my ($metrics, @pod_array) = _metrics( $id );
    my ($graph_metrics, $min, $max) = update_latencies_metrics( $metrics ); 
    return { 
        metrics         => $graph_metrics, 
        min             => $min, 
        max             => $max,
        unit_interval   => int(($max - $min)/10),
        series          => get_series( @pod_array )
    };
}

sub runtime_metrics {
    my $metrics = shift;

    my ($graph_metrics, $min, $max) = ({}, 0, 0);

    foreach my $id ( keys %$metrics ) {
        my $label = _get_label( $id );
        my $value = $metrics->{$id}->{OVERALL_RunTime_ms};
        $graph_metrics->{$label} = $value;
        $min = $value if ( $value < $min );
        $max = $value if ( $value > $max );
    }
    return ($graph_metrics, $min, $max);
}

sub throughput_metrics {
    my $metrics = shift;

    my ($graph_metrics, $min, $max) = ({}, 0, 0);

    foreach my $id ( keys %$metrics ) {
        my $label = _get_label( $id );
        my $value = int($metrics->{$id}->{OVERALL_Throughput_ops_sec});
        $graph_metrics->{$label} = $value;
        $min = $value if ( $value < $min );
        $max = $value if ( $value > $max );
    }
    return ($graph_metrics, $min, $max);
}

sub operations_metrics {
    my $metrics = shift;

    my ($graph_metrics, $min, $max, $series) = ({}, 0, 0, []);

    foreach my $id ( keys %$metrics ) {
        foreach ( qw( READ UPDATE INSERT ) ) {
            my $label = ucfirst(lc($_));
            if ( exists $metrics->{$id}->{$_.'_Operations'} ) {
                $graph_metrics->{$label} += $metrics->{$id}->{$_.'_Operations'} - $metrics->{$id}->{$_.'_Return_OK'};
                $max = $graph_metrics->{$label} if ( $graph_metrics->{$label} > $max ); 
            }
        }
    }
    $max ||= 10;
    foreach my $metric ( keys %$graph_metrics ) {
        push @$series, { dataField => $metric, displayText => $metric };
    }
    return ($graph_metrics, $min, $max, $series);
}

sub read_latencies_metrics {
    my $metrics = shift;

    my ($graph_metrics, $min, $max) = ([], 0, 0);

    my $metric_lookup = {
        READ_AverageLatency_us          => 'Average',
        READ_MaxLatency_us              => 'Max',
        READ_MinLatency_us              => 'Min',
        READ_95thPercentileLatency_us   => '95th perc.',
        READ_99thPercentileLatency_us   => '99th perc.'
    };

    foreach my $metric ( qw(
        READ_AverageLatency_us
        READ_MinLatency_us
        READ_95thPercentileLatency_us
        READ_99thPercentileLatency_us
    )) {
        my $metric_item = { metric => $metric_lookup->{$metric} };
        foreach my $id ( keys %$metrics ) {
            my $label = _get_label( $id );
            my $value = int($metrics->{$id}->{$metric}) || 0;
            $metric_item->{$label} = $value;
            $min = $value if ( $value < $min );
            $max = $value if ( $value > $max );
        }
        push @$graph_metrics, $metric_item;
    }
    return ($graph_metrics, $min, $max);
}

sub insert_latencies_metrics {
    my $metrics = shift;

    my ($graph_metrics, $min, $max) = ([], 0, 0);

    my $metric_lookup = {
        INSERT_AverageLatency_us          => 'Average',
        INSERT_MaxLatency_us              => 'Max',
        INSERT_MinLatency_us              => 'Min',
        INSERT_95thPercentileLatency_us   => '95th perc.',
        INSERT_99thPercentileLatency_us   => '99th perc.'
    };

    foreach my $metric ( qw(
        INSERT_AverageLatency_us
        INSERT_MinLatency_us
        INSERT_95thPercentileLatency_us
        INSERT_99thPercentileLatency_us
    )) {
        my $metric_item = { metric => $metric_lookup->{$metric} };
        foreach my $id ( keys %$metrics ) {
            my $label = _get_label( $id );
            my $value = int($metrics->{$id}->{$metric}) || 0;
            $metric_item->{$label} = $value;
            $min = $value if ( $value < $min );
            $max = $value if ( $value > $max );
        }
        push @$graph_metrics, $metric_item;
    }
    return ($graph_metrics, $min, $max);
}

sub update_latencies_metrics {
    my $metrics = shift;

    my ($graph_metrics, $min, $max) = ([], 0, 0);

    my $metric_lookup = {
        UPDATE_AverageLatency_us          => 'Average',
        UPDATE_MaxLatency_us              => 'Max',
        UPDATE_MinLatency_us              => 'Min',
        UPDATE_95thPercentileLatency_us   => '95th perc.',
        UPDATE_99thPercentileLatency_us   => '99th perc.'
    };

    foreach my $metric ( qw(
        UPDATE_AverageLatency_us
        UPDATE_MinLatency_us
        UPDATE_95thPercentileLatency_us
        UPDATE_99thPercentileLatency_us
    )) {
        my $metric_item = { metric => $metric_lookup->{$metric} };
        foreach my $id ( keys %$metrics ) {
            my $label = _get_label( $id );
            my $value = int($metrics->{$id}->{$metric}) || 0;
            $metric_item->{$label} = $value;
            $min = $value if ( $value < $min );
            $max = $value if ( $value > $max );
        }
        push @$graph_metrics, $metric_item;
    }
    return ($graph_metrics, $min, $max);
}

sub _get_label {
    my $id = shift;
    if ( $id =~ /(\w|-)*-(\d+)/) {
        return $2;
    }
    return $id;
}

sub get_series {
    my @series = ();

    foreach my $pod ( @_ ) {
        if ( $pod =~ /(\w|-)*-(\d+)/) {
            push @series, { dataField => "$2", displayText => "$2" };
        }
    }
    return \@series;
}
1; 
