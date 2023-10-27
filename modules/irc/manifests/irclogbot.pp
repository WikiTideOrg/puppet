# class: irc::irclogbot
class irc::irclogbot {
    include ::irc

    file { '/etc/irclogbot':
        ensure => directory,
    }

    git::clone { 'mwclient':
        ensure    => present,
        directory => '/etc/irclogbot/mwclient',
        origin    => 'https://github.com/mwclient/mwclient',
        require   => File['/etc/irclogbot'],
    }

    $wikitidebots_password = lookup('passwords::irc::wikitidebots')
    $wikitidelogbot_password = lookup('passwords::mediawiki::wikitidelogbot')
    $wikitidelogbot_consumer_token = lookup('passwords::mediawiki::wikitidelogbot_consumer_token')
    $wikitidelogbot_consumer_secret = lookup('passwords::mediawiki::wikitidelogbot_consumer_secret')
    $wikitidelogbot_access_token = lookup('passwords::mediawiki::wikitidelogbot_access_token')
    $wikitidelogbot_access_secret = lookup('passwords::mediawiki::wikitidelogbot_access_secret')

    file { '/etc/irclogbot/adminlog.py':
        ensure => present,
        source => 'puppet:///modules/irc/logbot/adminlog.py',
        notify => Service['logbot'],
    }

    file { '/etc/irclogbot/adminlogbot.py':
        ensure => present,
        source => 'puppet:///modules/irc/logbot/adminlogbot.py',
        mode   => '0755',
        notify => Service['logbot'],
    }

    file { '/etc/irclogbot/config.py':
        ensure  => present,
        content => template('irc/logbot/config.py'),
        notify  => Service['logbot'],
    }

    systemd::service { 'logbot':
        ensure  => present,
        content => systemd_template('logbot'),
        restart => true,
    }
}
