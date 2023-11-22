# === Class services::restbase
class services::restbase {
    include services

    stdlib::ensure_packages('libsqlite3-dev')

    group { 'restbase':
        ensure => present,
    }

    user { 'restbase':
        ensure     => present,
        gid        => 'restbase',
        shell      => '/bin/false',
        home       => '/srv/restbase',
        managehome => false,
        system     => true,
    }

    git::clone { 'restbase':
        ensure             => present,
        directory          => '/srv/restbase',
        origin             => 'https://github.com/wikimedia/restbase',
        branch             => 'v1.1.4',
        owner              => 'restbase',
        group              => 'restbase',
        mode               => '0755',
        recurse_submodules => true,
        require            => [
            User['restbase'],
            Group['restbase']
        ],
    }

    exec { 'restbase_npm':
        command     => 'npm install --cache /tmp/npm_cache_restbase --no-optional --only=production',
        creates     => '/srv/restbase/node_modules',
        cwd         => '/srv/restbase',
        path        => '/usr/bin',
        environment => 'HOME=/srv/restbase',
        user        => 'restbase',
        require     => [
            Git::Clone['restbase'],
            Package['nodejs']
        ]
    }

    ssl::wildcard { 'services wildcard': }

    nginx::site { 'restbase':
        ensure => present,
        source => 'puppet:///modules/services/nginx/restbase',
    }

    file { '/etc/mediawiki/restbase':
        ensure  => directory,
        require => File['/etc/mediawiki'],
    }

    $wikis = loadyaml('/etc/puppetlabs/puppet/services/services.yaml')

    file { '/etc/mediawiki/restbase/config.yaml':
        ensure  => present,
        content => template('services/restbase/config.yaml.erb'),
        require => File['/etc/mediawiki/restbase'],
        notify  => Service['restbase'],
    }

    file { '/etc/mediawiki/restbase/wikitide_project_v1.yaml':
        ensure  => present,
        source  => 'puppet:///modules/services/restbase/wikitide_project_v1.yaml',
        require => File['/etc/mediawiki/restbase'],
        notify  => Service['restbase'],
    }

    file { '/etc/mediawiki/restbase/wikitide_project_sys.yaml':
        ensure  => present,
        source  => 'puppet:///modules/services/restbase/wikitide_project_sys.yaml',
        require => File['/etc/mediawiki/restbase'],
        notify  => Service['restbase'],
    }

    file { '/etc/mediawiki/restbase/mathoid.yaml':
        ensure  => present,
        source  => 'puppet:///modules/services/restbase/mathoid.yaml',
        require => File['/etc/mediawiki/restbase'],
        notify  => Service['restbase'],
    }

    systemd::service { 'restbase':
        ensure  => present,
        content => systemd_template('restbase'),
        restart => true,
        require => Git::Clone['restbase'],
    }
}
