# SPDX-License-Identifier: Apache-2.0
# Megaraid controler
class raid::megaraid {
    include raid

    ensure_packages('megacli')

    file { '/usr/lib/nagios/plugins/get_raid_status_megacli.py':
        source  => 'puppet:///modules/raid/get_raid_status_megacli',
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => Package['nagios-nrpe-plugin'],
    }

    monitoring::nrpe { 'get_raid_status_megacli':
        command => '/usr/local/lib/nagios/plugins/get_raid_status_megacli -c',
    }

    monitoring::services { 'MegaRAID':
        check_command => "${raid::check_raid} megacli",
    }
}
