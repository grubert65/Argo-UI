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

get '/log' => sub {
    my $workflow_name = query_parameters->get('name');
    my $log = $argo_client->workflow_log( $workflow_name );
    my @log = split(/\n/, $log);
    shift @log;
    my $trimmed = join("\n", @log);

    if ( $workflow_name =~ /^ycsb/ ) {
        my $y = YCSB::Metrics->new();
        $y->load_metrics( $trimmed );
    }
    return $trimmed;
};


true;
