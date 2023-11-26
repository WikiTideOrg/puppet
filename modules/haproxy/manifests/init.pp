# == Class: haproxy
#
# === Parameters
#
# [*logging*]
#   If set to true, logs will be saved to disk under /var/log/haproxy/haproxy.log.
#   It will work only if 'log /dev/log local0 info' is set. This implementation
#   will simply direct *all* haproxy logs.
#
# [*monitor*]
#   If set to false, monitoring will not be set up for icinga. Defaults to true.
#   Useful for places where monitoring is not appropriate or impossible via icinga
#   such as cloud or perhaps a PoC system
#
# [*monitor_check_haproxy*]
#   If set to false, monitoring based on icinga check_haproxy will be disabled.
#   This can be useful on certain environments where access to the HAProxy stats socket
#   needs to be as restricted as possible.
# [*systemd_override*]
#   Override system-provided unit. Defaults to false
#
# [*systemd_content*]
#   Content used to create the systemd::service. If not provided a default template
#   located on haproxy/haproxy.service.erb is used
#
# [*config_content*]
#   Content used to populate /etc/haproxy/haproxy.cfg. If not provided a default template
#   located on haproxy/haproxy.cfg.erb is used

class haproxy(
    $template                         = 'haproxy/haproxy.cfg.erb',
    $socket                           = '/run/haproxy/haproxy.sock',
    $pid                              = '/run/haproxy/haproxy.pid',
    $monitor                          = true,
    $monitor_check_haproxy            = true,
    $logging                          = false,
    Boolean $systemd_override         = false,
    Optional[String] $systemd_content = undef,
    Optional[String] $config_content  = undef,
) {

    package { [
        'socat',
        'haproxy',
    ]:
        ensure => present,
    }

    if $socket == '/run/haproxy/haproxy.sock' or $pid == '/run/haproxy/haproxy.pid' {
        systemd::tmpfile { 'haproxy':
            content => 'd /run/haproxy 0775 root haproxy',
        }
    }
    # /etc/haproxy is created by installing the haproxy package.
    # however manging ig in puppet means we can drop files into this directory
    # and not have to worry about dependencies as file objects get an auto require
    # for any managed parents directories
    file { ['/etc/haproxy', '/etc/haproxy/conf.d']:
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
    }

    $haproxy_config_content = $config_content? {
        undef   => template($template),
        default => $config_content,
    }

    file { '/etc/haproxy/haproxy.cfg':
        ensure  => present,
        mode    => '0444',
        owner   => 'root',
        group   => 'root',
        content => $haproxy_config_content,
        notify  => Service['haproxy'],
    }

    # defaults file cannot be dynamic anymore on systemd
    # pregenerate them on systemd start/reload
    file { '/usr/local/bin/generate_haproxy_default.sh':
        ensure => absent,
    }

    # The ExecStart script is different on buster compared to earlier debians
    $exec_start = debian::codename::lt('buster') ? {
        true    => '/usr/sbin/haproxy-systemd-wrapper',
        default => '/usr/sbin/haproxy -Ws',
    }

    file { '/etc/default/haproxy':
        ensure  => present,
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        content => template('haproxy/haproxy.default.erb'),
        notify  => Service['haproxy'],
    }

    $systemd_service_content = $systemd_content? {
        undef   => template('haproxy/haproxy.service.erb'),
        default => $systemd_content,
    }

    systemd::service { 'haproxy':
        override       => $systemd_override,
        content        => $systemd_service_content,
        service_params => {'restart' => '/bin/systemctl reload haproxy.service',}
    }

    if $monitor {
        $ensure_monitoring = bool2str($monitor_check_haproxy, 'present', 'absent')

        file { "/usr/local/lib/nagios/plugins/${title}":
            ensure  => stdlib::ensure($ensure_monitoring, 'file'),
            source  => $source,
            content => template('haproxy/check_haproxy.erb'),
            owner   => 'root',
            group   => 'root',
            mode    => '0555',
        }

        monitoring::nrpe { 'haproxy process':
            command => '/usr/lib/nagios/plugins/check_procs -c 1: -C haproxy'
        }

        monitoring::nrpe { 'haproxy alive':
            ensure  => bool2str($monitor_check_haproxy, 'present', 'absent'),
            command => '/usr/bin/sudo /usr/local/lib/nagios/plugins/check_haproxy --check=alive'
        }
    }

    if $logging {
        file { '/var/log/haproxy':
          ensure => directory,
          owner  => 'root',
          group  => 'adm',
          mode   => '0750',
        }

        logrotate::conf { 'haproxy':
          ensure => present,
          source => 'puppet:///modules/haproxy/haproxy.logrotate',
        }

        rsyslog::conf { 'haproxy':
          source   => 'puppet:///modules/haproxy/haproxy.rsyslog',
          priority => 49,
          require  => File['/var/log/haproxy'],
        }

        # The debian package originaly will cause the creation
        # of this file, it will be simply confusing if it remains there
        file { '/var/log/haproxy.log':
          ensure => absent,
        }
    }
}
