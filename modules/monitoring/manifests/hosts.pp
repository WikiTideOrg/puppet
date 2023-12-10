define monitoring::hosts (
    $ensure      = present,
    $contacts    = lookup('contactgroups', {'default_value' => [ 'sre' ]}),
) {
    @@icinga2::object::host { $title:
        ensure  => $ensure,
        import  => ['generic-host'],
        address => $facts['networking']['hostname'] ? { # lint:ignore:selector_inside_resource
            'cloud1' => $facts['networking']['interfaces']['vmbr1']['ip'],
            default  => $facts['networking']['ip'],
        },
#        address6 => $facts['networking']['ip6'],
        target  => '/etc/icinga2/conf.d/puppet_hosts.conf',
        vars    => {
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
