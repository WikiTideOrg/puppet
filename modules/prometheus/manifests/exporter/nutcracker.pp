class prometheus::exporter::nutcracker {
    stdlib::ensure_packages('prometheus-nutcracker-exporter')

    service { 'prometheus-nutcracker-exporter':
        ensure  => running,
        require => Package['prometheus-nutcracker-exporter'],
    }
}
