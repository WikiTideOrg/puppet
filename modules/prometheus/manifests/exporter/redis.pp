# = Class: prometheus::exporter::redis
#
class prometheus::exporter::redis (
    String $redis_password = lookup('passwords::redis::master'),
) {

    stdlib::ensure_packages([
        'python3-prometheus-client',
        'python3-redis',
    ])

    file { '/usr/local/bin/prometheus-jobqueue-stats':
        ensure  => file,
        mode    => '0555',
        owner   => 'root',
        group   => 'root',
        content => template('prometheus/redis/prometheus-jobqueue-stats.py.erb')
    }

    file { '/etc/redis_exporter':
        ensure => directory,
        mode   => '0755',
        owner  => 'prometheus',
        group  => 'prometheus',
    }

    file { '/usr/local/bin/redis_exporter':
        ensure => file,
        mode   => '0555',
        owner  => 'root',
        group  => 'root',
        source => 'puppet:///modules/prometheus/redis/redis_exporter',
        notify => Service['prometheus-redis-exporter'],
    }

    file { '/etc/default/prometheus-redis':
        ensure  => present,
        content => template('prometheus/prometheus-redis-default.erb'),
        notify  => Service['prometheus-redis-exporter'],
    }

    systemd::service { 'prometheus-redis-exporter':
        ensure  => present,
        content => systemd_template('prometheus-redis-exporter'),
        restart => true,
        require => [
            File['/etc/default/prometheus-redis'],
            File['/usr/local/bin/redis_exporter']
        ]
    }

    # Collect every minute
    cron { 'prometheus_jobqueue_stats':
        ensure  => present,
        user    => 'root',
        command => '/usr/bin/python3 /usr/local/bin/prometheus-jobqueue-stats --outfile /var/lib/prometheus/node.d/jobqueue.prom',
    }

    $firewall_rules_str = join(
        query_facts("networking.domain='${facts['networking']['domain']}' and Class[Role::Prometheus]", ['networking'])
        .map |$key, $value| {
            "${value['networking']['ip']} ${value['networking']['ip6']}"
        }
        .flatten()
        .unique()
        .sort(),
        ' '
    )
    ferm::service { 'prometheus redis_exporter':
        proto  => 'tcp',
        port   => '9121',
        srange => "(${firewall_rules_str})",
    }
}
