#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";


# use this block if you don't need middleware, and only have a single target Dancer app to run here
use Argo::UI;

Argo::UI->to_app;

=begin comment
# use this block if you want to include middleware such as Plack::Middleware::Deflater

use Argo::UI;
use Plack::Builder;

builder {
    enable 'Deflater';
    Argo::UI->to_app;
}

=end comment

=cut

=begin comment
# use this block if you want to mount several applications on different path

use Argo::UI;
use Argo::UI_admin;

use Plack::Builder;

builder {
    mount '/'      => Argo::UI->to_app;
    mount '/admin'      => Argo::UI_admin->to_app;
}

=end comment

=cut

