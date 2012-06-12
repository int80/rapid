package Rapid;

use Moose;
use Rapid::Config;
use Rapid::LazySchema;
use Path::Class qw(file);
use Class::MOP;
use FindBin;

# our app name should be set in $Rapid::APP_NAME
our $APP_NAME;

# exported vars
our ($config, $schema);
our $_config;

# set up exports
use Exporter::Tidy
    default => [],
    _map => {
        '$config' => \$config,
        '$schema' => \$schema,
    };

setup();

sub setup {
    my $package = __PACKAGE__;
    die "Please define \$${package}::APP_NAME before extending $package"
        unless $APP_NAME;

    # load config
    $_config = Rapid::Config->new(
        app_name => $APP_NAME,
        app_root => find_app_root(),
    );
    $config = $_config->get;

    # load schema
    $schema = Rapid::LazySchema->new(
        config_obj => $_config,
    );
}

# traverses parent directories of the current script being run,
# looking for a directory containing '.app_root'
sub find_app_root {
    my ($class) = @_;

    # traverse upwards until we find '.app_root'
    my $root = file($FindBin::RealBin)->dir;
    while ($root && ! -e $root->file('.app_root')) {
        if ($root eq $root->parent) {
            # we are at /
            # .app_root was not found
            die qq/Failed to locate application root.
You must have an '.app_root' file located in the root directory of your application.
Current search path: $FindBin::RealBin/;
        }
        
        $root = $root->parent;
    }

    return $root;
}

1;
