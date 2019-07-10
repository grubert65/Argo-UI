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

get '/ycsb_chart_data' => sub {
    my $id = query_parameters->get('id');
    debug "Workflow ID: $id";

    content_type 'application/json';
    return encode_json({
            metrics => [
                { metric => 'Rt(ms)', 3075499422 => 30, 3075499423 => 15, 3075499424 =>  25},
                { metric => 'Thr(op/s)', 3075499422 => 25, 3075499423 => 25, 3075499424 =>  30},
                { metric => '[R] Avg Lat(us)', 3075499422 => 30, 3075499423 => 20, 3075499424 =>  25},
                { metric => '[R] Min Lat(us)', 3075499422 => 35, 3075499423 => 25, 3075499424 =>  45},
                { metric => '[R] Max Lat(us)', 3075499422 => 35, 3075499423 => 25, 3075499424 =>  45},
                { metric => '[R] 95th Lat(us),', 3075499422 => 20, 3075499423 => 20, 3075499424 =>  25},
                { metric => '[R] 99th Lat(us)', 3075499422 => 30, 3075499423 => 20, 3075499424 =>  30},
                { metric => '[R] RetOK', 3075499422 => 60, 3075499423 => 45, 3075499424 =>  90},
                { metric => '[R] Op', 3075499422 => 60, 3075499423 => 45, 3075499424 =>  90},
                { metric => '[I] Op', 3075499422 => 60, 3075499423 => 45, 3075499424 =>  90},
                { metric => '[I] Avg Lat(us)', 3075499422 => 60, 3075499423 => 45, 3075499424 =>  90},
                { metric => '[I] Min Lat(us)', 3075499422 => 60, 3075499423 => 45, 3075499424 =>  90},
                { metric => '[I] Max Lat(us)', 3075499422 => 60, 3075499423 => 45, 3075499424 =>  90},
                { metric => '[I] 95th Lat(us)', 3075499422 => 60, 3075499423 => 45, 3075499424 =>  90},
                { metric => '[I] 99th Lat(us)', 3075499422 => 60, 3075499423 => 45, 3075499424 =>  90},
                { metric => '[I] RetOK', 3075499422 => 60, 3075499423 => 45, 3075499424 =>  90},
                { metric => '[U] Op', 3075499422 => 60, 3075499423 => 45, 3075499424 =>  90},
                { metric => '[U] Avg Lat(us)', 3075499422 => 60, 3075499423 => 45, 3075499424 =>  90},
                { metric => '[U] Min Lat(us)', 3075499422 => 60, 3075499423 => 45, 3075499424 =>  90},
                { metric => '[U] Max Lat(us)', 3075499422 => 60, 3075499423 => 45, 3075499424 =>  90},
                { metric => '[U] 95th Lat(us)', 3075499422 => 60, 3075499423 => 45, 3075499424 =>  90},
                { metric => '[U] 99th Lat(us)', 3075499422 => 60, 3075499423 => 45, 3075499424 =>  90},
                { metric => '[U] RetOK', 3075499422 => 60, 3075499423 => 45, 3075499424 =>  90}
            ],
            series => [
                { dataField =>  '3075499422', displayText =>  '3075499422 (Load)'},
                { dataField =>  '3075499423', displayText =>  '3075499423 (run)'},
                { dataField =>  '3075499424', displayText =>  '3075499424 (run)'}
            ]
    });
};

true;
