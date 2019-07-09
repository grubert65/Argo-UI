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


true;
