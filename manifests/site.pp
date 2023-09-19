# servers

node 'cloud1.wikiforge.net' {
    include base
    include role::cloud
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

node 'jobrunner11.wikiforge.net' {
    include base
    include role::mediawiki
    include role::irc
}


node 'misc1.wikiforge.net' {
    include base
    include role::mail
    include role::openldap
    include role::roundcubemail
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

node 'phorge11.wikiforge.net' {
    include base
    include role::phorge
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
