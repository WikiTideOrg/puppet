# = Class: role::snappymail
#
# Sets up a web based mail server.
#
# = Parameters
#
# [*db_host*]
#   The database hostname to connect to.
#
# [*db_name*]
#   The database name to use.
#
# [*db_user_name*]
#   The database user to use to connect to the database.
#
# [*db_user_password*]
#   The database user password to use to connect to the datbase.
#
class role::snappymail (
    String $db_host               = 'db1.wikitide.net',
    String $db_name               = 'snappymail',
    String $db_user_name          = 'snappymail',
    String $db_user_password      = lookup('passwords::roundcubemail'),
) {

    class { 'snappymail':
        db_host               => $db_host,
        db_name               => $db_name,
        db_user_name          => $db_user_name,
        db_user_password      => $db_user_password ,
    }

    $firewall_rules_str = join(
        query_facts("networking.domain='${facts['networking']['domain']}' and Class[Role::Varnish] or Class[Role::Icinga2]", ['networking'])
        .map |$key, $value| {
            if $value['networking']['interfaces']['ens19'] {
                "${value['networking']['interfaces']['ens19']['ip']} ${value['networking']['interfaces']['ens19']['ip6']}"
            } else {
                "${value['networking']['ip']} ${value['networking']['ip6']}"
            }
        }
        .flatten()
        .unique()
        .sort(),
        ' '
    )

    ferm::service { 'http':
        proto   => 'tcp',
        port    => '80',
        srange  => "(${firewall_rules_str})",
        notrack => true,
    }

    ferm::service { 'https':
        proto   => 'tcp',
        port    => '443',
        srange  => "(${firewall_rules_str})",
        notrack => true,
    }

    motd::role { 'snappymail':
        description => 'webmail (Snappymail) host',
    }
}
