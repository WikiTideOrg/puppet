# class: role::cloud
class role::cloud {
    include ::cloud
    include raid::perccli

    $firewall_rules_str = join(
        query_facts("networking.domain='${facts['networking']['domain']}' and Class[Role::Cloud]", ['networking'])
        .map |$key, $value| {
            "${value['networking']['ip']} ${value['networking']['ip6']}"
        }
        .flatten()
        .unique()
        .sort(),
        ' '
    )

    ferm::service { 'proxmox port 5900:5999':
        proto  => 'tcp',
        port   => '5900:5999',
        srange => "(${firewall_rules_str})",
    }

    ferm::service { 'proxmox port 5404:5405':
        proto  => 'udp',
        port   => '5404:5405',
        srange => "(${firewall_rules_str})",
    }

    ferm::service { 'proxmox port 3128':
        proto  => 'tcp',
        port   => '3128',
        srange => "(${firewall_rules_str})",
    }

    ferm::service { 'proxmox port 4789':
        proto  => 'udp',
        port   => '4789',
        srange => "(${firewall_rules_str})",
    }

    ferm::service { 'proxmox port 8006':
        proto  => 'tcp',
        port   => '8006',
        # srange => "(${firewall_rules_str})", for now!
    }

    ferm::service { 'proxmox port 111':
        proto  => 'tcp',
        port   => '111',
        srange => "(${firewall_rules_str})",
    }

    ferm::service { 'cloud-ssh':
        proto => 'tcp',
        port  => '22',
    }

    motd::role { 'role::cloud':
        description => 'Proxmox host',
    }
}
