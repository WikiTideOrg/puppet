# SPDX-License-Identifier: Apache-2.0
# Megaraid controler
class raid::megaraid {
    include raid

    stdlib::ensure_packages('megacli')

    file { '/usr/lib/nagios/plugins/get_raid_status_megacli.py':
        source  => 'puppet:///modules/raid/get_raid_status_megacli',
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
    }

    monitoring::nrpe { 'get_raid_status_megacli':
        command => '/usr/local/lib/nagios/plugins/get_raid_status_megacli -c',
    }

    monitoring::services { 'MegaRAID':
        check_command  => "${raid::check_raid} megacli",
        check_interval => $raid::check_interval,
        retry_interval => $raid::retry_interval,
        event_command  => 'raid_handler',
        vars           => {
            raid_controller => 'megacli',
        },
    }
}
