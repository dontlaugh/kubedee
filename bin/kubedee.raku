# cli help
# https://docs.raku.org/language/create-cli#sub_USAGE
use JSON::Fast;
use App::Kubedee;

my $kubedee_version = "1.0.0";
my $home = %*ENV{'HOME'};
my $kubedee_dir = "{$home}/.local/share/kubedee";
my $kubedee_config_dir = "{$home}/.config/kubedee";
my $kubedee_cache_dir = "{$kubedee_config_dir}/cache/{$kubedee_version}";
my $install_psps = False;


my %*SUB-MAIN-OPTS =
  :named-anywhere,
;

class Cluster {
    has $!name;

    # network-id is stored on disk in our cluster config
    has $!network-id;
}

class LXD {
    has $!project = "default";

    has $!base-network-id = "kubedee-";

    method create_network(::CLASS:U $lxd, Str $name --> Str) {
        #my $rand;
        #$rand ~= ('0' .. 'z').pick() for 1..5;
        my $network-id = "{$!base-network-id}{$name}";

        # check if it exists
        my $proc = run 'lxc', 'network', 'list', '--format=json', :out;
        my @parsed = from-json $proc.out.slurp: :close;
        my Bool $exists = True if grep $network-id, @parsed.map: &{ $_{'name'}};

        # create network if it doesn't exist
        unless $exists {
            run 'lxc', 'network', 'create', $network-id;
        }


        $network-id;
    }

}

class Kubedee {
    has $.dir;
    has $.config-dir;
    has $.cache-dir;

    method init-dirs {
        # make dirs;
        mkdir $.dir;
        mkdir $.config-dir;
        mkdir $.cache-dir;
    }

}

## Main subroutines
## todo: validate cluster name

multi sub MAIN('controller-ip', Str $cluster-name) {
    say "controller-ip...";
}
multi sub MAIN('create', 
    Str $cluster-name,
    Str :$kubernetes-version,
    Int :$num-worker = 2,
    Bool :$no-set-context,
    Array[Str] :@apiserver-set-hostnames,
    Str :$bin-dir = "./_output/bin",
) {
    say "create...";
    
    ## lxd ops
    # create network
    # create storage pool
    
    ## assemble k8s
    # download k8s binaries
    # copy k8s binaries
    # copy etcd binaries
    # copy crio files
    # copy runc binaries
    # copy cni plugins

    ## create CAs
    # etcd
    # k8s
    # aggregation

    ## create client certs
    # aggregation client
    # admin client
}

multi sub MAIN('up',
    Str $cluster-name,
    Str :$kubernetes-version,
    Int :$num-worker = 2,
    Bool :$no-set-context,
    Array[Str] :@apiserver-set-hostnames,
    Str :$bin-dir = "./_output/bin",
) {
    say "up...";
}

multi sub MAIN('start', Str $cluster-name) {
    # ensure cluster exists
    # gen random suffix

    # prep lxd container image
    # launch lxd container
    # configure worker (?)

}
multi sub MAIN('create-admin-sa', Str $cluster-name) {
}
multi sub MAIN('create-user-sa', Str $cluster-name) {
}
multi sub MAIN('delete', Str $cluster-name) {
}
multi sub MAIN('etcd-env', Str $cluster-name) {
}
multi sub MAIN('kubectl-env', Str $cluster-name) {
}
multi sub MAIN('list', Str $cluster-name) {
}
multi sub MAIN('smoke-test', Str $cluster-name) {
}
multi sub MAIN('start-worker', Str $cluster-name) {
}
multi sub MAIN('version') {
}

# TODO use this override
sub USAGE() {
    print Q:c:to/EOH/; 
kubedee - unreleased

Usage:
  kubedee [options] controller-ip <cluster name>     print the IPv4 address of the controller node
  kubedee [options] create <cluster name>            create a cluster
  kubedee [options] create-admin-sa <cluster name>   create admin service account in cluster
  kubedee [options] create-user-sa <cluster name>    create user service account in cluster (has 'edit' privileges)
  kubedee [options] delete <cluster name>            delete a cluster
  kubedee [options] etcd-env <cluster name>          print etcdctl environment variables
  kubedee [options] kubectl-env <cluster name>       print kubectl environment variables
  kubedee [options] list                             list all clusters
  kubedee [options] smoke-test <cluster name>        smoke test a cluster
  kubedee [options] start <cluster name>             start a cluster
  kubedee [options] start-worker <cluster name>      start a new worker node in a cluster
  kubedee [options] up <cluster name>                create + start in one command
  kubedee [options] version                          print kubedee version and exit

Options:
  --apiserver-extra-hostnames <hostname>[,<hostname>]   additional X509v3 Subject Alternative Name to set, comma separated
  --bin-dir <dir>                                       where to copy the k8s binaries from (default: ./_output/bin)
  --kubernetes-version <version>                        the release of Kubernetes to install, for example 'v1.12.0'
                                                        takes precedence over `--bin-dir`
  --no-set-context                                      prevent kubedee from adding a new kubeconfig context
  --num-worker <num>                                    number of worker nodes to start (default: 2)
EOH
}
