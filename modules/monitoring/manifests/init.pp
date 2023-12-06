class monitoring (
    String $db_host,
    String $db_name               = 'icinga',
    String $db_user               = 'icinga2',
    String $db_password           = undef,
    String $wikitidebots_password = undef,
    String $phorge_token          = undef,
    String $ticket_salt           = '',
    Optional[String] $icinga2_api_bind_host = undef,
) {
    stdlib::ensure_packages([
        'nagios-nrpe-plugin',
        'python3-dnspython',
        'python3-filelock',
        'python3-flask',
        'python3-tldextract',
        'python3-phabricator',
    ])

    group { 'nagios':
        ensure    => present,
        name      => 'nagios',
        system    => true,
        allowdupe => false,
    }

    # First installs can trip without this
    exec { 'apt_update_mariadb':
        command     => '/usr/bin/apt-get update',
        refreshonly => true,
        logoutput   => true,
    }

    stdlib::ensure_packages(
        'mariadb-client',
        {
            ensure  => present,
        },
    )

    class { '::icinga2':
        manage_repos => true,
        constants    => {
            'TicketSalt' => $ticket_salt
        }
    }

    class { '::icinga2::feature::api':
        bind_host   => $icinga2_api_bind_host,
        ca_host     => $facts['networking']['fqdn'],
        ticket_salt => $ticket_salt,
    }

    include ::icinga2::feature::command

    include ::icinga2::feature::notification

    include ::icinga2::feature::perfdata

    class{ '::icinga2::feature::idomysql':
        host          => $db_host,
        user          => $db_user,
        password      => $db_password,
        database      => $db_name,
        import_schema => false,
    }

    class { '::icinga2::feature::gelf':
        host => 'logging.wikitide.net',
    }

    file { '/etc/icinga2/conf.d/commands.conf':
        source  => 'puppet:///modules/monitoring/commands.conf',
        owner   => 'root',
        group   => 'root',
        mode    => '0664',
        require => Package['icinga2'],
        notify  => Service['icinga2'],
    }

    file { '/etc/icinga2/conf.d/groups.conf':
        source  => 'puppet:///modules/monitoring/groups.conf',
        owner   => 'root',
        group   => 'root',
        mode    => '0664',
        require => Package['icinga2'],
        notify  => Service['icinga2'],
    }

    file { '/etc/icinga2/conf.d/hosts.conf':
        source  => 'puppet:///modules/monitoring/hosts.conf',
        owner   => 'root',
        group   => 'root',
        mode    => '0664',
        require => Package['icinga2'],
        notify  => Service['icinga2'],
    }

    file { '/etc/icinga2/conf.d/notifications.conf':
        source  => 'puppet:///modules/monitoring/notifications.conf',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package['icinga2'],
        notify  => Service['icinga2'],
    }

    file { '/etc/icinga2/conf.d/services.conf':
        source  => 'puppet:///modules/monitoring/services.conf',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package['icinga2'],
        notify  => Service['icinga2'],
    }

    file { '/etc/icinga2/conf.d/templates.conf':
        source  => 'puppet:///modules/monitoring/templates.conf',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package['icinga2'],
        notify  => Service['icinga2'],
    }

    file { '/etc/icinga2/conf.d/timeperiods.conf':
        source  => 'puppet:///modules/monitoring/timeperiods.conf',
        owner   => 'root',
        group   => 'root',
        mode    => '0664',
        require => Package['icinga2'],
        notify  => Service['icinga2'],
    }

    file { '/etc/icinga2/conf.d/users.conf':
        source  => 'puppet:///modules/monitoring/users.conf',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package['icinga2'],
        notify  => Service['icinga2'],
    }

    file { '/etc/icinga2/scripts/mail-host-notification.sh':
        source  => 'puppet:///modules/monitoring/scripts/mail-host-notification.sh',
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => Package['icinga2'],
        notify  => Service['icinga2'],
    }

    file { '/etc/icinga2/scripts/mail-service-notification.sh':
        source  => 'puppet:///modules/monitoring/scripts/mail-service-notification.sh',
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => Package['icinga2'],
        notify  => Service['icinga2'],
    }

    file { '/etc/icinga2/scripts/irc-host-notification.sh':
        source  => 'puppet:///modules/monitoring/scripts/irc-host-notification.sh',
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => Package['icinga2'],
        notify  => Service['icinga2'],
    }

    file { '/etc/icinga2/scripts/irc-service-notification.sh':
        source  => 'puppet:///modules/monitoring/scripts/irc-service-notification.sh',
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => Package['icinga2'],
        notify  => Service['icinga2'],
    }

    $ssl = loadyaml('/etc/puppetlabs/puppet/ssl-cert/certs.yaml')
    $redirects = loadyaml('/etc/puppetlabs/puppet/ssl-cert/redirects.yaml')
    $sslcerts = merge( $ssl, $redirects )

    file { '/etc/icinga2/conf.d/ssl.conf':
        ensure  => 'present',
        content => template('monitoring/ssl.conf.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0664',
        require => Package['icinga2'],
        notify  => Service['icinga2'],
    }

    file { '/etc/icinga2/scripts/ssl-renew.sh':
        ensure => 'present',
        source => 'puppet:///modules/monitoring/scripts/ssl-renew.sh',
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
    }

    file { '/etc/icinga2/eventhandlers':
        ensure => 'directory',
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
    }

    file { '/etc/icinga2/eventhandlers/raid_handler':
        source  => 'puppet:///modules/monitoring/eventhandlers/raid_handler.py',
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => File['/etc/icinga2/eventhandlers'],
    }

    file { '/etc/phorge_sre-monitoring-bot.conf':
        ensure  => 'present',
        content => template('monitoring/bot/phorge_sre-monitoring-bot.conf.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0664',
        require => Package['python3-phabricator'],
    }

    # includes a irc bot to relay messages from icinga to irc
    class { '::monitoring::ircecho':
        wikitidebots_password => $wikitidebots_password,
    }

    file { '/usr/lib/nagios/plugins/check_icinga_config':
        source  => 'puppet:///modules/monitoring/check_icinga_config',
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => Package['nagios-nrpe-plugin'],
    }

    file { '/usr/lib/nagios/plugins/check_reverse_dns.py':
        source  => 'puppet:///modules/monitoring/check_reverse_dns.py',
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => Package['nagios-nrpe-plugin'],
    }

    file { '/usr/lib/nagios/plugins/check_mysql_connections.php':
        source  => 'puppet:///modules/monitoring/check_mysql_connections.php',
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => Package['nagios-nrpe-plugin'],
    }

    # Setup webhook for grafana to call
    file { '/usr/local/bin/grafana-webhook.py':
        ensure => present,
        source => 'puppet:///modules/monitoring/grafana-webhook.py',
        mode   => '0755',
        notify => Service['grafana-webhook'],
    }

    systemd::service { 'grafana-webhook':
        ensure  => present,
        content => systemd_template('grafana-webhook'),
        restart => true,
    }

    # Icinga monitoring
    monitoring::nrpe { 'Check correctness of the icinga configuration':
        command => '/usr/lib/nagios/plugins/check_icinga_config'
    }

    cron { 'remove_icinga2_perfdata_2_days':
        ensure  => present,
        command => '/usr/bin/find /var/spool/icinga2/perfdata -type f -mtime +2 -exec rm {} +',
        user    => 'root',
        hour    => 5,
        minute  => 0,
    }

    Icinga2::Object::Host <<||>> ~> Service['icinga2']
    Icinga2::Object::Service <<||>> ~> Service['icinga2']
}
