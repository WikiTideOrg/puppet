# = Class: role::openldap
#
# Sets up OpenLDAP
#
# = Parameters
#
class role::openldap (
    String $admin_password = lookup('profile::openldap::admin_password'),
    String $ldapvi_password = lookup('profile::openldap::ldapvi_password'),
) {
    ssl::wildcard { 'openldap wildcard': }

    class { 'openldap::server':
        ldaps_ifs => ['/'],
        ssl_ca    => '/etc/ssl/certs/ISRG_Root_X1.pem',
        ssl_cert  => '/etc/ssl/localcerts/wikitide.net.crt',
        ssl_key   => '/etc/ssl/private/wikitide.net.key',
        require   => Ssl::Wildcard['openldap wildcard']
    }

    openldap::server::database { 'dc=wikitide,dc=org':
        ensure    => present,
        directory => '/var/lib/ldap/wikitide',
        rootdn    => 'cn=admin,dc=wikitide,dc=org',
        rootpw    => $admin_password,
    }

    # LDAP monitoring support
    openldap::server::database { 'cn=monitor':
        ensure  => present,
        backend => 'monitor',
    }

    # Allow everybody to try to bind
    openldap::server::access { '0 on dc=wikitide,dc=org':
        what   => 'attrs=userPassword,shadowLastChange',
        access => [
            'by dn="cn=admin,dc=wikitide,dc=org" write',
            'by group.exact="cn=Administrators,ou=groups,dc=wikitide,dc=org" write',
            'by self write',
            'by anonymous auth',
            'by * none',
        ],
    }

    # Allow admin users to manage things and authed users to read
    openldap::server::access { '1 on dc=wikitide,dc=org':
        what   => 'dn.children="dc=wikitide,dc=org"',
        access => [
            'by group.exact="cn=Administrators,ou=groups,dc=wikitide,dc=org" write',
            'by users read',
            'by * break',
        ],
    }

    openldap::server::access { 'admin-monitor-access':
        ensure => present,
        what   => 'dn.subtree="cn=monitor"',
        suffix => 'cn=monitor',
        access => [
            'by dn="cn=admin,dc=wikitide,dc=org" write',
            'by dn="cn=monitor,dc=wikitide,dc=org" read',
            'by self write',
            'by * none',
        ],
    }

    # Modules
    openldap::server::module { 'back_mdb':
        ensure => present,
    }

    openldap::server::module { 'back_monitor':
        ensure => present,
    }

    openldap::server::module { 'memberof':
        ensure => present,
    }

    openldap::server::module { 'syncprov':
        ensure => present,
    }

    openldap::server::module { 'auditlog':
        ensure => present,
    }

    openldap::server::module { 'ppolicy':
        ensure => present,
    }

    openldap::server::module { 'deref':
        ensure => present,
    }

    openldap::server::module { 'unique':
        ensure => present,
    }

    openldap::server::overlay { 'memberof on dc=wikitide,dc=org':
        ensure => present,
    }

    # Schema
    openldap::server::schema { 'core':
        ensure => present,
        path   => '/etc/ldap/schema/core.schema',
    }

    openldap::server::schema { 'cosine':
        ensure => present,
        path   => '/etc/ldap/schema/cosine.schema',
    }

    openldap::server::schema { 'nis':
        ensure => present,
        path   => '/etc/ldap/schema/nis.ldif',
    }

    openldap::server::schema { 'inetorgperson':
        ensure => present,
        path   => '/etc/ldap/schema/inetorgperson.schema',
    }

    openldap::server::schema { 'dyngroup':
        ensure => present,
        path   => '/etc/ldap/schema/dyngroup.schema',
    }

    file { '/etc/ldap/schema/postfix.schema':
        source => 'puppet:///modules/role/openldap/postfix.schema',
    }

    openldap::server::schema { 'postfix':
        ensure  => present,
        path    => '/etc/ldap/schema/postfix.schema',
        require => File['/etc/ldap/schema/postfix.schema'],
    }

    openldap::server::schema { 'ppolicy':
        ensure => absent,
        path   => '/etc/ldap/schema/ppolicy.schema',
    }

    openldap::server::overlay { 'ppolicy':
        ensure  => present,
        suffix  => 'cn=config',
        overlay => 'ppolicy',
        options => {
            'olcPPolicyHashCleartext' => 'TRUE',
        },
    }

    class { 'openldap::client':
        base       => 'dc=wikitide,dc=org',
        uri        => ["ldaps://${facts['networking']['fqdn']}"],
        tls_cacert => '/etc/ssl/certs/ISRG_Root_X1.pem',
    }

    stdlib::ensure_packages('ldapvi')

    file { '/etc/ldapvi.conf':
        content => template('role/openldap/ldapvi.conf.erb'),
        mode    => '0440',
        owner   => 'root',
        group   => 'root',
    }

    file { '/usr/local/bin/modify-ldap-group':
        source => 'puppet:///modules/role/openldap/modify-ldap-group',
        mode   => '0550',
        owner  => 'root',
        group  => 'root',
    }

    file { '/usr/local/bin/modify-ldap-user':
        source => 'puppet:///modules/role/openldap/modify-ldap-user',
        mode   => '0550',
        owner  => 'root',
        group  => 'root',
    }

    $firewall_rules = join(
        query_facts('Class[Role::Mail] or Class[Role::Mediawiki] or Class[Role::Openldap]', ['ipaddress', 'ipaddress6'])
        .map |$key, $value| {
            "${value['ipaddress']} ${value['ipaddress6']}"
        }
        .flatten()
        .unique()
        .sort(),
        ' '
    )
    ferm::service { 'ldaps':
        proto  => 'tcp',
        port   => '636',
        srange => "(${firewall_rules})",
    }

    # restart slapd if it uses more than 50% of memory (T130593)
    cron { 'restart_slapd':
        ensure  => present,
        minute  => fqdn_rand(60, $title),
        command => "/bin/ps -C slapd -o pmem= | awk '{sum+=\$1} END { if (sum <= 50.0) exit 1 }' \
        && /bin/systemctl restart slapd >/dev/null 2>/dev/null",
    }

    motd::role { 'role::openldap':
        description => 'LDAP server',
    }
}
