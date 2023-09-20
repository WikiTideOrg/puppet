# servers

node 'cloud1.wikiforge.net' {
    include base
    include role::cloud
}

node 'bots1.wikiforge.net' {
    include base
}

node /^cp[3]\.wikiforge\.net$/ {
    include base
    include role::varnish
}

node 'db11.wikiforge.net' {
    include base
    include role::db
}

node 'jobchron11.wikiforge.net' {
    include base
    include role::redis
    include mediawiki::jobqueue::chron
}

node 'graylog11.wikiforge.net' {
    include base
    include role::graylog
}

node 'jobrunner11.wikiforge.net' {
    include base
    include role::mediawiki
    include role::irc
}

node 'mail11.wikiforge.net' {
    include base
    include role::mail
    include role::roundcubemail
}

node 'ldap11.wikiforge.net' {
    include base
    include role::openldap
}

node 'mem11.wikiforge.net' {
    include base
    include role::memcached
}

node /^mw1[12]\.wikiforge\.net$/ {
    include base
    include role::mediawiki
}

node /^ns[12]\.wikiforge\.net$/ {
    include base
    include role::dns
}

node 'os11.wikiforge.net' {
    include base
    include role::opensearch
}

node 'phorge11.wikiforge.net' {
    include base
    include role::phorge
}

node 'prometheus11.wikiforge.net' {
    include base
    include role::prometheus
}

node 'puppet1.wikiforge.net' {
    include base
    include role::postgresql
    include puppetdb::database
    include role::puppetserver
    include role::salt
    include role::ssl
}

node 'services1.wikiforge.net' {
    include base
    include role::services
}

node /^test(1|11)\.wikiforge\.net$/ {
    include base
    include role::mediawiki
}

# ensures all servers have basic class if puppet runs
node default {
    include base
}
