define monitoring::hosts (
    $ensure      = present,
    $contacts    = lookup('contactgroups', {'default_value' => [ 'sre' ]}),
) {
    @@icinga2::object::host { $title:
        ensure   => $ensure,
        import   => ['generic-host'],
    case $facts['networking']['hostname'] {
        'mw11', 'mw12': {
            address => $facts['networking']['interfaces']['ens19']['ip'],
        }
        default: {
          address => $facts['networking']['ip'],
        }
    }
#        address6 => $facts['networking']['ip6'],
        target   => '/etc/icinga2/conf.d/puppet_hosts.conf',
        vars     => {
            notification => {
                mail => {
                    groups => $contacts,
                },
                irc  => {
                    groups => [ 'icingaadmins' ],
                },
            },
        },
    }
}
