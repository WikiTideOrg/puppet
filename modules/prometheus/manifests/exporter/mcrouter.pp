# == Define: prometheus::exporter::mcrouter
#
# Prometheus exporter for mcrouter server metrics.
#
# = Parameters
#
# [*arguments*]
#   Additional command line arguments for prometheus-mcrouter-exporter.

define prometheus::exporter::mcrouter (
    $arguments = '',
) {
    stdlib::ensure_packages('daemon')
    file { '/opt/prometheus-mcrouter-exporter_0.1.0_amd64.deb':
        ensure => present,
        source => 'puppet:///modules/prometheus/packages/prometheus-mcrouter-exporter_0.1.0_amd64.deb',
    }

    package { 'prometheus-mcrouter-exporter':
        ensure   => installed,
        provider => dpkg,
        source   => '/opt/prometheus-mcrouter-exporter_0.1.0_amd64.deb',
        require  => File['/opt/prometheus-mcrouter-exporter_0.1.0_amd64.deb'],
    }

    file { '/etc/default/prometheus-mcrouter-exporter':
        ensure  => present,
        mode    => '0444',
        owner   => 'root',
        group   => 'root',
        content => "ARGS=\"${arguments}\"",
        notify  => Service['prometheus-mcrouter-exporter'],
    }

    service { 'prometheus-mcrouter-exporter':
        ensure  => running,
        require => Package['prometheus-mcrouter-exporter'],
    }
}
