define monitoring::services (
    $check_command,
    $host           = $facts['networking']['hostname'],
    $retries        = 3,
    $ensure         = present,
    $check_interval = '2m',
    $retry_interval = '1m',
    $event_command  = undef,
    $docs           = undef,
    $critical       = false,
    $vars           = undef,
) {
    @@icinga2::object::service { "${::hostname} ${title}":
        ensure                => $ensure,
        import                => ['generic-service'],
        host_name             => $host,
        display_name          => $title,
        check_command         => $check_command,
        max_check_attempts    => $retries,
        check_interval        => $check_interval,
        retry_interval        => $retry_interval,
        check_period          => '24x7',
        enable_passive_checks => true,
        enable_active_checks  => true,
        volatile              => false,
        event_command         => $event_command,
        notes_url             => $docs,
        target                => '/etc/icinga2/conf.d/puppet_services.conf',
        vars                  => $vars,
    }
}
