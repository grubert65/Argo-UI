package Argo::UI;
use Dancer2;
use Argo;
use YCSB::Metrics;
use Data::Printer;
use Argo::Utils qw(
    runtime_chart_data
    throughput_chart_data
    operations_chart_data
    read_latencies_chart_data
    insert_latencies_chart_data
    update_latencies_chart_data
    get_log
);

use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($DEBUG);

our $VERSION = '0.1';
our $argo_client = Argo->new(port => 8080);

get '/' => sub {
    template 'index' => { 'title' => 'Argo::UI' };
};

get '/ui' => sub {
    template 'argo' => { 'title' => 'Argo::UI' };
};

get '/workflows' => sub {
    return encode_json( $argo_client->workflows_as_list() );
};

get '/workflow_tree' => sub {
    my $workflows = $argo_client->workflows_as_tree();
    session 'workflows_steps' => $workflows;
    debug "STEPS: -------------\n".np($workflows);
    return encode_json( $workflows );
};

get '/log' => sub {
    my $id = query_parameters->get('id');
    my $log = get_log( $id );

    if ( $id =~ /^ycsb/ ) {
        my $y = YCSB::Metrics->new();
        $y->load_metrics( $log );
        debug "--------- $id Log: ------------------";
        debug $log;
        debug "--------- $id Metrics: ------------------";
        debug np( $y->{metrics} );

        my $metrics = session('metrics');
        $metrics->{$id} = $y;
        session 'metrics' => $metrics;
    }
    return $log;
};


get '/params' => sub {
    my $name = query_parameters->get('name');
    return encode_json( $argo_client->workflow_params( $name ) );
};

#=============================================================

=head2 overall_runtime_chart_data

=head3 INPUT

=head3 OUTPUT

=head3 DESCRIPTION

Retrieves the overall runtime metrics for all the ycsb pods in 
the current workflow.

Workflow:
- get ids of all pods steps of selected workflow id 
- get metrics from session
- for each pod id:
-- if pod metrics not in session => get pod metrics, update session
-- build graph data

=cut

#=============================================================
get '/overall_runtime_chart_data' => sub {

    my $id = query_parameters->get('id');
    debug "Workflow ID: $id";

    content_type 'application/json';

    my $charts_data = session('charts_data');
    if ( exists $charts_data->{$id}->{runtime} ) {
        return encode_json( $charts_data->{$id}->{runtime} );
    }

    my $steps = session('workflows_steps');
    my $data = runtime_chart_data( $id ); 

    my $chart_data = {
        metrics => [{
            metric => 'Runtime (ms)',
            %{$data->{metrics}},
        }],
        series  => $data->{series},
        valueAxis => {
            minValue    => $data->{min},
            maxValue    => $data->{max},
            unitInterval=> $data->{unit_interval},
            title       => {text => 'Overall Runtime'}
        }
    };

    debug "Graph DATA:";
    debug np($chart_data);
    $charts_data->{$id}->{runtime} = $chart_data;
    session 'charts_data' => $charts_data;

    return encode_json( $chart_data );
};

get '/overall_throughput_chart_data' => sub {
    my $id = query_parameters->get('id');
    debug "Workflow ID: $id";

    content_type 'application/json';

    my $charts_data = session('charts_data');
    if ( exists $charts_data->{$id}->{throughput} ) {
        return encode_json( $charts_data->{$id}->{throughput} );
    }

    my $steps = session('workflows_steps');
    my $data = throughput_chart_data( $id ); 

    my $chart_data = {
        metrics => [{
            metric => 'Throughput (ops/sec)', 
            %{$data->{metrics}},
        }],
        series  => $data->{series},
        valueAxis => {
            minValue    => $data->{min},
            maxValue    => $data->{max},
            unitInterval=> $data->{unit_interval},
            title       => {text => 'Overall Throughput'}
        }
    };

    debug "Graph DATA:";
    debug np($chart_data);
    $charts_data->{$id}->{throughput} = $chart_data;
    session 'charts_data' => $charts_data;

    return encode_json( $chart_data );
};

get '/operations_chart_data' => sub {
    my $id = query_parameters->get('id');
    debug "Workflow ID: $id";

    content_type 'application/json';

    my $charts_data = session('charts_data');
    if ( exists $charts_data->{$id}->{operations} ) {
        return encode_json( $charts_data->{$id}->{operations} );
    }

    my $steps = session('workflows_steps');
    my $data = operations_chart_data( $id ); 

    my $chart_data = {
        metrics => [{
            metric => 'Operations NOT OK',
            %{$data->{metrics}},
        }],
        series => $data->{series},
        valueAxis => {
            minValue    => $data->{min},
            maxValue    => $data->{max},
            unitInterval=> $data->{unit_interval},
            title       => {text => 'NOT OK Operations'}
        }
    };

    debug "Graph DATA:";
    debug np($chart_data);
    $charts_data->{$id}->{operations} = $chart_data;
    session 'charts_data' => $charts_data;

    return encode_json( $chart_data );
};

get '/read_latencies_chart_data' => sub {
    my $id = query_parameters->get('id');
    debug "Workflow ID: $id";

    content_type 'application/json';

    my $charts_data = session('charts_data');
    if ( exists $charts_data->{$id}->{read_latencies} ) {
        return encode_json( $charts_data->{$id}->{read_latencies} );
    }

    my $steps = session('workflows_steps');
    my $data = read_latencies_chart_data( $id ); 

    my $chart_data = {
        metrics => $data->{metrics},
        series => $data->{series},
        valueAxis => {
            minValue    => $data->{min},
            maxValue    => $data->{max},
            unitInterval=> $data->{unit_interval},
            title       => {text => 'Read Latencies (us)'}
        }
    };

    debug "Graph DATA:";
    debug np($chart_data);
    $charts_data->{$id}->{read_latencies} = $chart_data;
    session 'charts_data' => $charts_data;

    return encode_json( $chart_data );
};

get '/insert_latencies_chart_data' => sub {
    my $id = query_parameters->get('id');
    debug "Workflow ID: $id";

    content_type 'application/json';
    my $charts_data = session('charts_data');
    if ( exists $charts_data->{$id}->{insert_latencies} ) {
        return encode_json( $charts_data->{$id}->{insert_latencies} );
    }

    my $steps = session('workflows_steps');
    my $data = insert_latencies_chart_data( $id ); 

    my $chart_data = {
        metrics => $data->{metrics},
        series => $data->{series},
        valueAxis => {
            minValue    => $data->{min},
            maxValue    => $data->{max},
            unitInterval=> $data->{unit_interval},
            title       => {text => 'Insert Latencies (us)'}
        }
    };

    debug "Graph DATA:";
    debug np($chart_data);
    $charts_data->{$id}->{insert_latencies} = $chart_data;
    session 'charts_data' => $charts_data;

    return encode_json( $chart_data );
};

get '/update_latencies_chart_data' => sub {
    my $id = query_parameters->get('id');
    debug "Workflow ID: $id";

    content_type 'application/json';
    my $charts_data = session('charts_data');
    if ( exists $charts_data->{$id}->{update_latencies} ) {
        return encode_json( $charts_data->{$id}->{update_latencies} );
    }

    my $steps = session('workflows_steps');
    my $data = update_latencies_chart_data( $id ); 

    my $chart_data = {
        metrics => $data->{metrics},
        series => $data->{series},
        valueAxis => {
            minValue    => $data->{min},
            maxValue    => $data->{max},
            unitInterval=> $data->{unit_interval},
            title       => {text => 'Update Latencies (us)'}
        }
    };

    debug "Graph DATA:";
    debug np($chart_data);
    $charts_data->{$id}->{update_latencies} = $chart_data;
    session 'charts_data' => $charts_data;

    return encode_json( $chart_data );
};

true;
