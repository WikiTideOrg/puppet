# class: irc::cvtbot
class irc::cvtbot {
    $git_path = '/srv/cvtbot'
    $install_path = "$git_path/src"

    # FIXME: should be cvtbot, using relaybot for now
    $irc_password = lookup('passwords::irc::relaybot::irc_password')

    ensure_packages('mono-complete')

    file { $git_path:
        ensure => 'directory',
        owner  => 'irc',
        group  => 'irc',
        mode   => '0755',
        recurse => true,
    }

    git::clone { 'CVTBot':
        ensure    => present,
        origin    => 'https://github.com/Universal-Omega/CVTBot',
        directory => $git_path,
        owner     => 'irc',
        group     => 'irc',
        mode      => '0755',
        require   => File[$git_path],
    }

    file { "${install_path}/CVTBot.ini":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('irc/cvtbot/CVTBot.ini.erb'),
        require => Git::Clone['CVTBot'],
        notify  => Service['cvtbot'],
    }

    systemd::service { 'cvtbot':
        ensure  => present,
        content => systemd_template('cvtbot'),
        restart => true,
        require => [
            Git::Clone['CVTBot'],
            Package['mono-complete'],
            File["${install_path}/CVTBot.ini"],
        ],
    }
}
