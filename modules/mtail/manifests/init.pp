# SPDX-License-Identifier: Apache-2.0
# == Class: mtail
#
# Setup mtail to scan $logs and report metrics based on programs in /etc/mtail.
#
# === Parameters
#
# [*logs*]
#   Array of log files to follow
#
# [*port*]
#   TCP port to listen to for Prometheus-style metrics
#
# [*service_ensure*]
#   Whether mtail.service should be present or absent.

class mtail (
    Array[Stdlib::Unixpath] $logs   = ['/var/log/syslog'],
    Stdlib::Port $port              = 3903,
    VMlib::Ensure $service_ensure  = 'present',
    String $group                   = 'root',
    String $additional_args         = ''
) {
    stdlib::ensure_packages('mtail')

    file { '/etc/default/mtail':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        content => template('mtail/default.erb'),
        notify  => Service['mtail'],
    }

    systemd::service { 'mtail':
        ensure   => $service_ensure,
        content  => init_template('mtail', 'systemd_override'),
        override => true,
        restart  => true,
    }
}
