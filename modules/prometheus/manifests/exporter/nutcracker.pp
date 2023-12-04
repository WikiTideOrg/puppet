class prometheus::exporter::nutcracker {
    file { '/opt/prometheus-nutcracker-exporter_0.3_all.deb':
        ensure => present,
        source => 'puppet:///modules/prometheus/packages/prometheus-nutcracker-exporter_0.3_all.deb',
    }

    package { 'prometheus-nutcracker-exporter':
        ensure   => installed,
        provider => dpkg,
        source   => '/opt/prometheus-nutcracker-exporter_0.3_all.deb',
        require  => File['/opt/prometheus-nutcracker-exporter_0.3_all.deb'],
    }

    service { 'prometheus-nutcracker-exporter':
        ensure  => running,
        require => Package['prometheus-nutcracker-exporter'],
    }
}
