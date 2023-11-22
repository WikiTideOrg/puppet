# == Class: cloud

class cloud {
    file { '/etc/apt/trusted.gpg.d/proxmox.gpg':
        ensure => present,
        source => 'puppet:///modules/cloud/key/proxmox.gpg',
    }

    apt::source { 'proxmox_apt':
        location => 'http://download.proxmox.com/debian/pve',
        release  => $facts['os']['distro']['codename'],
        repos    => 'pve-no-subscription',
        require  => File['/etc/apt/trusted.gpg.d/proxmox.gpg'],
        notify   => Exec['apt_update_proxmox'],
    }

    apt::pin { 'proxmox_pin':
        priority => 600,
        origin   => 'download.proxmox.com'
    }

    # First installs can trip without this
    exec {'apt_update_proxmox':
        command     => '/usr/bin/apt-get update',
        refreshonly => true,
        logoutput   => true,
        require     => Apt::Pin['proxmox_pin'],
    }

    package { ['proxmox-ve', 'open-iscsi']:
        ensure  => present,
        require => Apt::Source['proxmox_apt']
    }

    logrotate::conf { 'pve':
        ensure => present,
        source => 'puppet:///modules/cloud/pve.logrotate.conf',
    }

    logrotate::conf { 'pve-firewall':
        ensure => present,
        source => 'puppet:///modules/cloud/pve-firewall.logrotate.conf',
    }

    stdlib::ensure_packages(['freeipmi-tools'])
}
