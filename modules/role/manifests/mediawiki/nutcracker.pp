# === Class role::mediawiki::nutcracker
class role::mediawiki::nutcracker (
    Array[Variant[Stdlib::Host,String]] $memcached_servers = lookup('memcached_servers', {'default_value' => []}),
) {

    #include prometheus::exporter::nutcracker

    $nutcracker_pools = {
        'memcached' => {
            auto_eject_hosts     => true,
            distribution         => 'ketama',
            hash                 => 'md5',
            listen               => '127.0.0.1:11212',
            preconnect           => true,
            server_connections   => 1,
            server_failure_limit => 3,
            server_retry_timeout => 30000,  # milliseconds
            timeout              => 250,    # milliseconds
            servers              => $memcached_servers,
        },
    }

    # Ship a tmpfiles.d configuration to create /run/nutcracker
    systemd::tmpfile { 'nutcracker':
        content => 'd /run/nutcracker 0755 nutcracker nutcracker - -'
    }

    class { 'nutcracker':
        mbuf_size => '64k',
        pools     => $nutcracker_pools,
    }

    systemd::unit { 'nutcracker':
        content  => "[Service]\nCPUAccounting=yes\nRestart=always\n",
        override => true,
    }

    monitoring::nrpe { 'nutcracker process':
        command => '/usr/lib/nagios/plugins/check_procs -c 1:1 -u nutcracker -C nutcracker',
        docs    => 'https://meta.wikitide.org/wiki/Tech:Icinga/MediaWiki_Monitoring#Nutcracker'
    }

    monitoring::nrpe { 'nutcracker port':
        command => '/usr/lib/nagios/plugins/check_tcp -H 127.0.0.1 -p 11212 --timeout=2',
        docs    => 'https://meta.wikitide.org/wiki/Tech:Icinga/MediaWiki_Monitoring#Nutcracker'
    }

    ferm::rule { 'skip_nutcracker_conntrack_out':
        desc  => 'Skip outgoing connection tracking for Nutcracker',
        table => 'raw',
        chain => 'OUTPUT',
        rule  => 'proto tcp sport (6378:6382 11212) NOTRACK;',
    }

    ferm::rule { 'skip_nutcracker_conntrack_in':
        desc  => 'Skip incoming connection tracking for Nutcracker',
        table => 'raw',
        chain => 'PREROUTING',
        rule  => 'proto tcp dport (6378:6382 11212) NOTRACK;',
    }
}
