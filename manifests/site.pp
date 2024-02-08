# servers

node 'cloud1.wikitide.net' {
    include base
    include role::cloud
}

node /^cp[456]\.wikitide\.net$/ {
    include base
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

node 'jobrunner1.wikitide.net' {
    include base
    include role::mediawiki
}

node 'mem1.wikitide.net' {
    include base
    include role::memcached
}

node /^mw[12]\.wikitide\.net$/ {
    include base
    include role::mediawiki
}

node 'puppet1.wikitide.net' {
    include base
    include role::postgresql
    include puppetdb::database
    include role::puppetserver
    include role::salt
    include role::ssl
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

# ensures all servers have basic class if puppet runs
node default {
    include base
}
