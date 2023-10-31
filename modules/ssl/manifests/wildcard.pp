# define: ssl::wildcard
define ssl::wildcard (
    $ssl_cert_path = '/etc/ssl/localcerts',
    $ssl_cert_key_private_path = '/etc/ssl/private',
    $ssl_cert_key_private_group = 'ssl-cert',
) {

    if !defined(File[$ssl_cert_path]) {
        file { $ssl_cert_path:
            ensure  => directory,
            owner   => 'root',
            group   => $ssl_cert_key_private_group,
            mode    => '0775',
            require => Package['ssl-cert'],
        }
    }

    if defined(Service['nginx']) {
        $restart_nginx = Service['nginx']
    } else {
        $restart_nginx = undef
    }

    if !defined(File["${ssl_cert_path}/wikitide.net.crt"]) {
        file { "${ssl_cert_path}/wikitide.net.crt":
            ensure => 'present',
            source => 'puppet:///ssl/certificates/wikitide.net.crt',
            notify => $restart_nginx,
        }
    }

    if !defined(File["${ssl_cert_key_private_path}/wikitide.net.key"]) {
        file { "${ssl_cert_key_private_path}/wikitide.net.key":
            ensure    => 'present',
            source    => 'puppet:///ssl-keys/wikitide.net.key',
            owner     => 'root',
            group     => $ssl_cert_key_private_group,
            mode      => '0660',
            show_diff => false,
            notify    => $restart_nginx,
        }
    }

    if !defined(File["${ssl_cert_path}/wikitide.org.crt"]) {
        file { "${ssl_cert_path}/wikitide.org.crt":
            ensure => 'present',
            source => 'puppet:///ssl/certificates/wikitide.org.crt',
            notify => $restart_nginx,
        }
    }

    if !defined(File["${ssl_cert_key_private_path}/wikitide.org.key"]) {
        file { "${ssl_cert_key_private_path}/wikitide.org.key":
            ensure    => 'present',
            source    => 'puppet:///ssl-keys/wikitide.org.key',
            owner     => 'root',
            group     => $ssl_cert_key_private_group,
            mode      => '0660',
            show_diff => false,
            notify    => $restart_nginx,
        }
    }
}
