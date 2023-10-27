# servers

node 'cloud1.wikitide.net' {
    include base
    include role::cloud
}

node 'bast11.wikitide.net' {
    include base
    include role::bastion
}
node 'bots1.wikitide.net' {
    include base
}

node /^cp[123456]\.wikitide\.net$/ {
    include base
    include role::varnish
}

node 'db11.wikitide.net' {
    include base
    include role::db
}

node 'jobchron11.wikitide.net' {
    include base
    include role::redis
    include mediawiki::jobqueue::chron
}

node 'graylog11.wikitide.net' {
    include base
    include role::graylog
}

node 'jobrunner11.wikitide.net' {
    include base
    include role::mediawiki
    include role::irc
}

node 'mail11.wikitide.net' {
    include base
    include role::mail
    include role::roundcubemail
}

node 'ldap11.wikitide.net' {
    include base
    include role::openldap
}

node 'mem11.wikitide.net' {
    include base
    include role::memcached
}

node 'mon11.wikitide.net' {
    include base
    include role::grafana
    include role::icinga2
}
node /^mw1[123]\.wikitide\.net$/ {
    include base
    include role::mediawiki
}

node 'ns11.wikitide.net' {
    include base
    include role::dns
}

node 'os11.wikitide.net' {
    include base
    include role::opensearch
}

node 'phorge11.wikitide.net' {
    include base
    include role::phorge
}

node 'prometheus11.wikitide.net' {
    include base
    include role::prometheus
}

node 'puppet1.wikitide.net' {
    include base
    include role::postgresql
    include puppetdb::database
    include role::puppetserver
    include role::salt
    include role::ssl
}

node 'services11.wikitide.net' {
    include base
    include role::services
}

node 'test11.wikitide.net' {
    include base
    include role::mediawiki
    include role::memcached
    include role::redis
    include mediawiki::jobqueue::chron
}

# ensures all servers have basic class if puppet runs
node default {
    include base
}
