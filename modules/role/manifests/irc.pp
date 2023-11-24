# role: irc
class role::irc {
    include irc::irclogbot
    include irc::relaybot
    include irc::cvtbot
    include irc::limnoria

    class { 'irc::ircrcbot':
        nickname     => 'WikiTideRC',
        network      => 'irc.libera.chat',
        network_port => '6697',
        channel      => '#wikitide-feed',
        udp_port     => '5070',
    }

    class { 'irc::irclogserverbot':
        nickname     => 'WikiTideLSBot',
        network      => 'irc.libera.chat',
        network_port => '6697',
        channel      => '#wikitide-sre',
        udp_port     => '5071',
    }

    $firewall_irc_rules_str = join(
        query_facts("networking.domain='${facts['networking']['domain']}' and Class[Role::Mediawiki]", ['networking'])
        .map |$key, $value| {
            "${value['networking']['ip']} ${value['networking']['ip6']}"
        }
        .flatten()
        .unique()
        .sort(),
        ' '
    )
    ferm::service { 'ircrcbot':
        proto  => 'udp',
        port   => '5070',
        srange => "(${firewall_irc_rules_str})",
    }

    $firewall_all_rules_str = join(
        query_facts("networking.domain='${facts['networking']['domain']}' and Class[Base]", ['networking'])
        .map |$key, $value| {
            "${value['networking']['ip']} ${value['networking']['ip6']}"
        }
        .flatten()
        .unique()
        .sort(),
        ' '
    )
    ferm::service { 'irclogserverbot':
        proto  => 'udp',
        port   => '5071',
        srange => "(${firewall_all_rules_str})",
    }

    motd::role { 'role::irc':
        description => 'IRC bots server',
    }
}
