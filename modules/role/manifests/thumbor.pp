# role: thumbor
class role::thumbor(
    Array[Stdlib::Host] $memcached_servers = lookup('thumbor::memcached_servers'),
    Array[String] $memcached_servers_nutcracker = lookup('thumbor::memcached_servers_nutcracker'),
    Stdlib::Port $graylog_port = lookup('thumbor::graylog_port'),
    Array[String] $swift_sharded_containers = lookup('swift::proxy::shard_container_list', {'merge' => 'unique', default_value => []}),
    Array[String] $swift_private_containers = lookup('swift::proxy::private_container_list', {'merge' => 'unique', default_value => []}),
    String $thumbor_mediawiki_shared_secret = lookup('thumbor::mediawiki::shared_secret'),
    Hash[String, Hash] $global_swift_account_keys = lookup('swift::accounts_keys'),
){
    require base::memory_cgroup

    class { 'thumbor::nutcracker':
        thumbor_memcached_servers => $memcached_servers_nutcracker,
    }

    class { 'thumbor':
        graylog_host => 'localhost',
        graylog_port => $graylog_port,
    }

    # Get the local site's swift credentials
    $swift_account_keys = $global_swift_account_keys[$::site]
    class { 'thumbor::swift':
        swift_key                       => $swift_account_keys['mw_thumbor'],
        swift_private_key               => $swift_account_keys['mw_thumbor-private'],
        swift_sharded_containers        => $swift_sharded_containers,
        swift_private_containers        => $swift_private_containers,
        thumbor_mediawiki_shared_secret => $thumbor_mediawiki_shared_secret,
    }

    $firewall_rules_str = join(
        query_facts("networking.domain='${facts['networking']['domain']}' and Class[Role::Swift] or Class[Role::Mediawiki] or Class[Role::Varnish] or Class[Role::Icinga2]", ['networking'])
        .map |$key, $value| {
            if $value['networking']['interfaces']['ens19'] {
                $value['networking']['interfaces']['ens19']['ip6']
            } else {
                "${value['networking']['ip']} ${value['networking']['ip6']}"
            }
        }
        .flatten()
        .unique()
        .sort(),
        ' '
    )

    ferm::service { 'thumbor':
        proto  => 'tcp',
        port   => '8800',
        srange => "(${firewall_rules_str})",
    }

    $thumbor_memcached_servers_ferm = join($memcached_servers, ' ')

    ferm::service { 'memcached_memcached_role':
        proto  => 'tcp',
        port   => '11211',
        srange => "(@resolve((${thumbor_memcached_servers_ferm})))",
    }

    motd::role { 'role::thumbor':
        description => 'Thumbor',
    }
}
