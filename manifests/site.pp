# servers

node /^cloud[1234]\.wikitide\.net$/ {
    include base
    include role::cloud
}

node 'bast1.wikitide.net' {
    include base
    include role::bastion
}

node 'bots1.wikitide.net' {
    include base
    include role::irc
}

node /^cp[12456]\.wikitide\.net$/ {
    include base
    include role::varnish
}

node 'cp3.wikitide.net' {
    include base
    include role::dns
    include role::varnish
}

node 'db1.wikitide.net' {
    include base
    include role::db
}

node 'jobchron1.wikitide.net' {
    include base
    include role::poolcounter
    include role::redis
    include mediawiki::jobqueue::chron
}

node 'graylog1.wikitide.net' {
    include base
    include role::graylog
}

node 'jobrunner1.wikitide.net' {
    include base
    include role::mediawiki
}

node 'mail1.wikitide.net' {
    include base
    include role::mail
    include role::snappymail
}

node 'ldap1.wikitide.net' {
    include base
    include role::openldap
}

node 'matomo1.wikitide.net' {
    include base
    include role::matomo
}

node 'mem1.wikitide.net' {
    include base
    include role::memcached
}

node 'mon1.wikitide.net' {
    include base
    include role::grafana
    include role::icinga2
}

node /^mw[1234]\.wikitide\.net$/ {
    include base
    include role::mediawiki
}

node 'ns1.wikitide.net' {
    include base
    include role::dns
}

node 'os1.wikitide.net' {
    include base
    include role::opensearch
}

node 'phorge1.wikitide.net' {
    include base
    include role::phorge
}

node 'prometheus1.wikitide.net' {
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

node 'reports1.wikitide.net' {
    include base
    include role::reports
}

node 'services1.wikitide.net' {
    include base
    include role::services
}

node 'swiftac1.wikitide.net' {
    include base
    include role::swift
}

node 'swiftobject1.wikitide.net' {
    include base
    include role::swift
}

node 'swiftproxy1.wikitide.net' {
    include base
    include role::swift
}

node 'test1.wikitide.net' {
    include base
    include role::mediawiki
    include role::memcached
    include role::poolcounter
    include role::redis
    include mediawiki::jobqueue::chron
}

# ensures all servers have basic class if puppet runs
node default {
    include base
}
