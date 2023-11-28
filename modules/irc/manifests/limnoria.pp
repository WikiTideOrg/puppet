# class: irc::limnoria
class irc::limnoria {
    $install_path = '/srv/limnoria'

    $irc_password = lookup('passwords::irc::wikitidebots')

    stdlib::ensure_packages(
        'limnoria',
        {
            ensure   => present,
            provider => 'pip3',
            require  => Package['python3-pip'],
        },
    )

    file { $install_path:
        ensure => 'directory',
        owner  => 'irc',
        group  => 'irc',
        mode   => '0755',
    }

    file { "${install_path}/WikiTide.conf":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('irc/limnoria/WikiTide.conf.erb'),
        notify  => Service['limnoria'],
    }

    systemd::service { 'limnoria':
        ensure  => present,
        content => systemd_template('limnoria'),
        restart => true,
        require => File["${install_path}/WikiTide.conf"],
    }

    monitoring::nrpe { 'IRC Limnoria Bot':
        command => '/usr/lib/nagios/plugins/check_procs -a limnoria -c 1:1'
    }
}
