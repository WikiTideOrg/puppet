# class: phorge
class phorge (
    Integer $request_timeout = lookup('phorge::php::request_timeout', {'default_value' => 60}),
) {
    ensure_packages(['mariadb-client', 'python3-pygments', 'subversion'])

    $wikitide_s3_access = lookup('phorge::aws_s3_access_key_wikitide')
    $wikitide_s3_secret = lookup('phorge::aws_s3_access_secret_key_wikitide')

    $fpm_config = {
        'include_path'                    => '".:/usr/share/php"',
        'error_log'                       => 'syslog',
        'pcre.backtrack_limit'            => 5000000,
        'date.timezone'                   => 'UTC',
        'display_errors'                  => 0,
        'error_reporting'                 => 'E_ALL & ~E_STRICT',
        'mysql'                           => { 'connect_timeout' => 3 },
        'default_socket_timeout'          => 60,
        'session.upload_progress.enabled' => 0,
        'enable_dl'                       => 0,
        'opcache' => {
                'enable' => 1,
                'interned_strings_buffer' => 40,
                'memory_consumption' => 256,
                'max_accelerated_files' => 20000,
                'max_wasted_percentage' => 10,
                'validate_timestamps' => 1,
                'revalidate_freq' => 10,
        },
        'max_execution_time' => 230,
        'post_max_size' => '10M',
        'track_errors' => 'Off',
        'upload_max_filesize' => '10M',
    }

    $core_extensions =  [
        'curl',
        'gd',
        'gmp',
        'intl',
        'mbstring',
        'ldap',
        'zip',
    ]

    $php_version = lookup('php::php_version')

    # Install the runtime
    class { '::php':
        ensure         => present,
        version        => $php_version,
        sapis          => ['cli', 'fpm'],
        config_by_sapi => {
            'fpm' => $fpm_config,
        },
    }

    $core_extensions.each |$extension| {
        php::extension { $extension:
            package_name => "php${php_version}-${extension}",
            sapis        => ['cli', 'fpm'],
        }
    }

    class { '::php::fpm':
        ensure => present,
        config => {
            'emergency_restart_interval'  => '60s',
            'emergency_restart_threshold' => $facts['processors']['count'],
            'process.priority'            => -19,
        },
    }

    # Extensions that require configuration.
    php::extension {
        default:
            sapis        => ['cli', 'fpm'];
        'apcu':
            ;
        'mailparse':
            priority     => 21;
        'mysqlnd':
            package_name => '',
            priority     => 10;
        'xml':
            package_name => "php${php_version}-xml",
            priority     => 15;
        'mysqli':
            package_name => "php${php_version}-mysql";
    }

    # XML
    php::extension{ [
        'dom',
        'simplexml',
        'xmlreader',
        'xmlwriter',
        'xsl',
    ]:
        package_name => '',
    }

    $fpm_workers_multiplier = lookup('php::fpm::fpm_workers_multiplier', {'default_value' => 1.5})
    $fpm_min_child = lookup('php::fpm::fpm_min_child', {'default_value' => 4})

    $num_workers = max(floor($facts['processors']['count'] * $fpm_workers_multiplier), $fpm_min_child)
    php::fpm::pool { 'www':
        config => {
            'pm'                        => 'static',
            'pm.max_children'           => $num_workers,
            'request_terminate_timeout' => $request_timeout,
            'request_slowlog_timeout'   => 15,
        }
    }

    nginx::site { 'issue-tracker.wikitide.org':
        ensure => present,
        source => 'puppet:///modules/phorge/issue-tracker.wikitide.org.conf',
    }

    ssl::wildcard { 'phorge wildcard': }

    file { '/srv/phorge':
        ensure => directory,
        owner  => 'www-data',
        group  => 'www-data',
    }

    git::clone { 'arcanist':
        ensure    => present,
        directory => '/srv/phorge/arcanist',
        origin    => 'https://we.phorge.it/source/arcanist',
        require   => File['/srv/phorge'],
    }

    git::clone { 'errorpages':
        ensure    => present,
        directory => '/srv/phorge/ErrorPages',
        origin    => 'https://github.com/WikiTideOrg/ErrorPages',
        require   => File['/srv/phorge'],
    }

    git::clone { 'phorge':
        ensure    => present,
        directory => '/srv/phorge/phorge',
        origin    => 'https://we.phorge.it/source/phorge',
        require   => File['/srv/phorge'],
    }

    git::clone { 'phorge-extensions':
        ensure    => latest,
        directory => '/srv/phorge/phorge/src/extensions',
        origin    => 'https://github.com/WikiForge/phorge-extensions',
        require   => File['/srv/phorge'],
    }

    file { '/srv/phorge/repos':
        ensure => directory,
        mode   => '0755',
        owner  => 'www-data',
        group  => 'www-data',
    }

    file { '/srv/phorge/repos/wikitide':
        ensure  => directory,
        owner   => 'www-data',
        group   => 'www-data',
        require => File['/srv/phorge/repos'],
    }

    file { '/srv/phorge/images':
        ensure => directory,
        mode   => '0755',
        owner  => 'www-data',
        group  => 'www-data',
    }

    file { '/srv/phorge/phorge/conf/custom':
        ensure  => directory,
        owner   => 'www-data',
        group   => 'www-data',
        require => File['/srv/phorge'],
    }

    $module_path = get_module_path($module_name)
    $phorge_yaml = loadyaml("${module_path}/data/config.yaml")
    $phorge_private = {
        'amazon-s3.access-key' => $wikitide_s3_access,
        'amazon-s3.secret-key' => $wikitide_s3_secret,
        'mysql.pass' => lookup('passwords::db::phorge'),
    }

    $phorge_setting = {
        # smtp
        'cluster.mailers'      => [
            {
                'key'          => 'wikitide-smtp',
                'type'         => 'smtp',
                'options'      => {
                    'host'     => 'mail.wikitide.net',
                    'port'     => 587,
                    'user'     => lookup('passwords::mail::noreply_username'),
                    'password' => lookup('passwords::mail::noreply'),
                    'protocol' => 'tls',
                    'message-id' => true,
                },
            },
        ],
    }

    $phorge_settings = merge($phorge_yaml, $phorge_private, $phorge_setting)

    file { '/srv/phorge/phorge/conf/local/local.json':
        ensure  => present,
        content => to_json_pretty($phorge_settings),
        notify  => [
            Service['phd-wikitide'],
        ],
        require => Git::Clone['phorge'],
    }

    file { '/srv/phorge/phorge/conf/custom/wikitide.conf.php':
        ensure  => present,
        source  => 'puppet:///modules/phorge/wikitide.conf.php',
        notify  => [
            Service['phd-wikitide'],
        ],
        require => Git::Clone['phorge'],
    }

    systemd::service { 'phd-wikitide':
        ensure  => present,
        content => systemd_template('phd-wikitide'),
        restart => true,
        require => File['/srv/phorge/phorge/conf/local/local.json'],
    }

    cron { 'backups-phorge':
        ensure   => present,
        command  => '/usr/local/bin/wikitide-backup backup phorge > /var/log/phorge-backup.log',
        user     => 'root',
        minute   => '0',
        hour     => '1',
        monthday => ['1', '15'],
    }
}
