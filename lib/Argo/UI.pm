package Argo::UI;
use Dancer2;
use Argo;
use YCSB::Metrics;

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
    return encode_json( $argo_client->workflows_as_tree() );
};

get '/log' => sub {
    my $id = query_parameters->get('id');
    my $log = $argo_client->workflow_log( $id );
    my @log = split(/\n/, $log);
    shift @log;
    my $trimmed = join("\n", @log);

    if ( $id =~ /^ycsb/ ) {
        my $y = YCSB::Metrics->new();
        $y->load_metrics( $trimmed );
    }
    return $trimmed;
};

get '/params' => sub {
    my $name = query_parameters->get('name');
    return encode_json( $argo_client->workflow_params( $name ) );
};

get '/overall_runtime_chart_data' => sub {
    my $id = query_parameters->get('id');
    debug "Workflow ID: $id";

    content_type 'application/json';
    return encode_json({
            metrics => [
                { metric => 'Runtime (ms)', 3075499422 => 323557, 3075499423 => 244845, 3075499424 =>  288709},
            ],
            series => [
                { dataField =>  '3075499422', displayText =>  '3075499422 (Load)'},
                { dataField =>  '3075499423', displayText =>  '3075499423 (run)'},
                { dataField =>  '3075499424', displayText =>  '3075499424 (run)'}
            ],
            valueAxis => {
                minValue    =>  0,
                maxValue    => 350000,
                unitInterval=> 50000,
                title       => {text => 'Overall Runtime'}
            }
    });
};

get '/overall_throughput_chart_data' => sub {
    my $id = query_parameters->get('id');
    debug "Workflow ID: $id";

    content_type 'application/json';
    return encode_json({
            metrics => [
                { 
                    metric => 'Throughput (ops/sec)', 
                    3075499422 => 309, 
                    3075499423 => 408, 
                    3075499424 => 346
                }
            ],
            series => [
                { dataField =>  '3075499422', displayText =>  '3075499422 (Load)'},
                { dataField =>  '3075499423', displayText =>  '3075499423 (run)'},
                { dataField =>  '3075499424', displayText =>  '3075499424 (run)'}
            ],
            valueAxis => {
                minValue    =>  0,
                maxValue    => 450,
                unitInterval=> 50,
                title       => {text => 'Overall Throughput'}
            }
    });
};

get '/operations_chart_data' => sub {
    my $id = query_parameters->get('id');
    debug "Workflow ID: $id";

    content_type 'application/json';
    return encode_json({
            metrics => [
                { metric => 'Insert', 3075499422 => 0, 3075499423 => 0, 3075499424 =>  0},
                { metric => 'Read', 3075499422 => 0, 3075499423 => 0, 3075499424 =>  0},
                { metric => 'Update', 3075499422 => 0, 3075499423 => 0, 3075499424 =>  0},
            ],
            series => [
                { dataField =>  '3075499422', displayText =>  '3075499422 (Load)'},
                { dataField =>  '3075499423', displayText =>  '3075499423 (run)'},
                { dataField =>  '3075499424', displayText =>  '3075499424 (run)'}
            ],
            valueAxis => {
                minValue    =>  0,
                maxValue    => 1000,
                unitInterval=> 50,
                title       => {text => 'NOT OK Operations'}
            }
    });
};

get '/read_latencies_chart_data' => sub {
    my $id = query_parameters->get('id');
    debug "Workflow ID: $id";

    content_type 'application/json';
    return encode_json({
            metrics => [
                { metric => 'Average', 3075499422 => 30, 3075499423 => 20, 3075499424 =>  25},
                { metric => 'Min', 3075499422 => 35, 3075499423 => 25, 3075499424 =>  45},
                { metric => 'Max', 3075499422 => 35, 3075499423 => 25, 3075499424 =>  45},
                { metric => '95th percentile', 3075499422 => 20, 3075499423 => 20, 3075499424 =>  25},
                { metric => '99th percentile', 3075499422 => 30, 3075499423 => 20, 3075499424 =>  30},
            ],
            series => [
                { dataField =>  '3075499422', displayText =>  '3075499422 (Load)'},
                { dataField =>  '3075499423', displayText =>  '3075499423 (run)'},
                { dataField =>  '3075499424', displayText =>  '3075499424 (run)'}
            ],
            valueAxis => {
                minValue    =>  0,
                maxValue    => 1000,
                unitInterval=> 50,
                title       => {text => 'Read Latencies (us)'}
            }
    });
};

get '/insert_latencies_chart_data' => sub {
    my $id = query_parameters->get('id');
    debug "Workflow ID: $id";

    content_type 'application/json';
    return encode_json({
            metrics => [
                { metric => 'Average', 3075499422 => 30, 3075499423 => 20, 3075499424 =>  25},
                { metric => 'Min', 3075499422 => 35, 3075499423 => 25, 3075499424 =>  45},
                { metric => 'Max', 3075499422 => 35, 3075499423 => 25, 3075499424 =>  45},
                { metric => '95th percentile', 3075499422 => 20, 3075499423 => 20, 3075499424 =>  25},
                { metric => '99th percentile', 3075499422 => 30, 3075499423 => 20, 3075499424 =>  30},
            ],
            series => [
                { dataField =>  '3075499422', displayText =>  '3075499422 (Load)'},
                { dataField =>  '3075499423', displayText =>  '3075499423 (run)'},
                { dataField =>  '3075499424', displayText =>  '3075499424 (run)'}
            ],
            valueAxis => {
                minValue    =>  0,
                maxValue    => 1000,
                unitInterval=> 50,
                title       => {text => 'Insert Latencies (us)'}
            }
    });
};

get '/update_latencies_chart_data' => sub {
    my $id = query_parameters->get('id');
    debug "Workflow ID: $id";

    content_type 'application/json';
    return encode_json({
            metrics => [
                { metric => 'Average', 3075499422 => 30, 3075499423 => 20, 3075499424 =>  25},
                { metric => 'Min', 3075499422 => 35, 3075499423 => 25, 3075499424 =>  45},
                { metric => 'Max', 3075499422 => 35, 3075499423 => 25, 3075499424 =>  45},
                { metric => '95th percentile', 3075499422 => 20, 3075499423 => 20, 3075499424 =>  25},
                { metric => '99th percentile', 3075499422 => 30, 3075499423 => 20, 3075499424 =>  30},
            ],
            series => [
                { dataField =>  '3075499422', displayText =>  '3075499422 (Load)'},
                { dataField =>  '3075499423', displayText =>  '3075499423 (run)'},
                { dataField =>  '3075499424', displayText =>  '3075499424 (run)'}
            ],
            valueAxis => {
                minValue    =>  0,
                maxValue    => 1000,
                unitInterval=> 50,
                title       => {text => 'Update Latencies (us)'}
            }
    });
};

true;
