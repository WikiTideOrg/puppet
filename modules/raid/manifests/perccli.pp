# SPDX-License-Identifier: Apache-2.0
# Dell PowerEdge RAID Controler
class raid::perccli {
    ensure_packages('perccli')

    file { '/usr/lib/nagios/plugins/get-raid-status-perccli.py':
        source  => 'puppet:///modules/raid/get-raid-status-perccli',
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => Package['nagios-nrpe-plugin'],
    }

    monitoring::nrpe { 'get_raid_status_perccli':
        command => '/usr/local/lib/nagios/plugins/get-raid-status-perccli',
    }

    monitoring::services { 'Dell PowerEdge RAID Controller':
        check_command => '/usr/local/lib/nagios/plugins/get-raid-status-perccli',
    }
}
