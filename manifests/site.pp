# servers

node /^cloud[1234]\.wikitide\.net$/ {
    include base
    include role::cloud
}

node 'bast21.wikitide.net' {
    include base
    include role::bastion
}

node 'bots21.wikitide.net' {
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

node 'db21.wikitide.net' {
    include base
    include role::db
}

node 'jobchron21.wikitide.net' {
    include base
    include role::poolcounter
    include role::redis
    include mediawiki::jobqueue::chron
}

node 'graylog21.wikitide.net' {
    include base
    include role::graylog
}

node 'jobrunner21.wikitide.net' {
    include base
    include role::mediawiki
}

node 'mail21.wikitide.net' {
    include base
    include role::mail
    include role::snappymail
}

node 'ldap21.wikitide.net' {
    include base
    include role::openldap
}

node 'matomo21.wikitide.net' {
    include base
    include role::matomo
}

node 'mem21.wikitide.net' {
    include base
    include role::memcached
}

node 'mon21.wikitide.net' {
    include base
    include role::grafana
    include role::icinga2
}
node /^mw2[1234]\.wikitide\.net$/ {
    include base
    include role::mediawiki
}

node 'ns1.wikitide.net' {
    include base
    include role::dns
}

node 'os21.wikitide.net' {
    include base
    include role::opensearch
}

node 'phorge21.wikitide.net' {
    include base
    include role::phorge
}

node 'prometheus21.wikitide.net' {
    include base
    include role::prometheus
}

node 'puppet21.wikitide.net' {
    include base
    include role::postgresql
    include puppetdb::database
    include role::puppetserver
    include role::salt
    include role::ssl
}

node 'services21.wikitide.net' {
    include base
    include role::services
}

node 'swiftac31.wikitide.net' {
    include base
    include role::swift
}

node 'swiftobject31.wikitide.net' {
    include base
    include role::swift
}

node 'swiftproxy31.wikitide.net' {
    include base
    include role::swift
}

node 'test21.wikitide.net' {
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
