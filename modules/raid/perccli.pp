# SPDX-License-Identifier: Apache-2.0
# Dell PowerEdge RAID Controler
class raid::perccli {
    ensure_packages('perccli')

    monitoring::nrpe { 'get_raid_status_perccli':
        command   => '/usr/local/lib/nagios/plugins/get-raid-status-perccli',
        sudo_user => 'root',
    }

    monitoring::services { 'Dell PowerEdge RAID Controller':
        check_command => '/usr/local/lib/nagios/plugins/get-raid-status-perccli',
    }
}
