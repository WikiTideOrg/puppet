# === Class mediawiki::jobqueue::runner
#
# Defines a jobrunner process for jobrunner selected machine only.
class mediawiki::jobqueue::runner (
    String $version,
) {
    if versioncmp($version, '1.40') >= 0 {
        $runner = "/srv/mediawiki/${version}/maintenance/run.php "
    } else {
        $runner = ''
    }

    class { 'mediawiki::jobqueue::shared':
        version => $version,
    }

    $wiki = lookup('mediawiki::jobqueue::wiki')
    ensure_packages('python3-xmltodict')

    systemd::service { 'jobrunner':
        ensure    => present,
        content   => systemd_template('jobrunner'),
        subscribe => File['/srv/jobrunner/jobrunner.json'],
        restart   => true,
    }

    if lookup('mediawiki::jobqueue::runner::cron', {'default_value' => false}) {
        cron { 'purge_checkuser':
            ensure  => present,
            command => "/usr/local/bin/foreachwikiindblist /srv/mediawiki/cache/databases-wikitide.json ${runner}/srv/mediawiki/${version}/extensions/CheckUser/maintenance/purgeOldData.php >> /var/log/mediawiki/cron/purge_checkuser.log",
            user    => 'www-data',
            minute  => '5',
            hour    => '6',
        }

        cron { 'purge_abusefilter':
            ensure  => present,
            command => "/usr/local/bin/foreachwikiindblist /srv/mediawiki/cache/databases-wikitide.json ${runner}/srv/mediawiki/${version}/extensions/AbuseFilter/maintenance/PurgeOldLogIPData.php >> /var/log/mediawiki/cron/purge_abusefilter.log",
            user    => 'www-data',
            minute  => '5',
            hour    => '18',
        }

        cron { 'managewikis':
            ensure  => present,
            command => "/usr/bin/php ${runner}/srv/mediawiki/${version}/extensions/CreateWiki/maintenance/manageInactiveWikis.php --wiki metawikitide --write >> /var/log/mediawiki/cron/managewikis.log",
            user    => 'www-data',
            minute  => '5',
            hour    => '12',
        }

        cron { 'update rottenlinks on all wikis':
            ensure   => present,
            command  => "/usr/local/bin/fileLockScript.sh /tmp/rotten_links_file_lock \"/usr/bin/nice -n 15 /usr/local/bin/foreachwikiindblist /srv/mediawiki/cache/databases-wikitide.json ${runner}/srv/mediawiki/${version}/extensions/RottenLinks/maintenance/updateExternalLinks.php\"",
            user     => 'www-data',
            minute   => '0',
            hour     => '0',
            month    => '*',
            monthday => [ '14', '28' ],
        }

        cron { 'generate sitemaps for all wikis':
            ensure  => present,
            command => "/usr/local/bin/foreachwikiindblist /srv/mediawiki/cache/databases-wikitide.json ${runner}/srv/mediawiki/${version}/extensions/WikiTideMagic/maintenance/generateWikiTideSitemap.php",
            user    => 'www-data',
            minute  => '0',
            hour    => '0',
            month   => '*',
            weekday => [ '6' ],
        }

        if $wiki == 'metawikitide' {
            $aws_s3_access_key = lookup('mediawiki::aws_s3_access_key')
            $aws_s3_access_secret_key = lookup('mediawiki::aws_s3_access_secret_key')
            ensure_packages(
                'boto3',
                {
                    ensure   => '1.26.144',
                    provider => 'pip3',
                    require  => Package['python3-pip'],
                },
            )

            cron { 'generate sitemap index':
                ensure  => present,
                command => "/usr/bin/python3 /srv/mediawiki/${version}/extensions/WikiTideMagic/py/generateSitemapIndex.py -B static.wikiforge.net -K ${aws_s3_access_key} -S ${aws_s3_access_secret_key} >> /var/log/mediawiki/cron/generate-sitemap-index.log",
                user    => 'www-data',
                minute  => '0',
                hour    => '0',
                month   => '*',
                weekday => [ '5' ],
            }
        }

            cron { 'purge_parsercache':
                ensure  => present,
                command => "/usr/bin/php ${runner}/srv/mediawiki/${version}/maintenance/purgeParserCache.php --age 432000 --msleep 200 --wiki metawikitide",
                user    => 'www-data',
                special => 'daily',
            }

            # Backups
            file { '/srv/backups':
                ensure => directory,
            }

            cron { 'backups-mediawiki-xml':
                ensure   => present,
                command  => '/usr/local/bin/wikiforge-backup backup mediawiki-xml > /var/log/mediawiki-xml-backup.log 2>&1',
                user     => 'root',
                minute   => '0',
                hour     => '1',
                monthday => ['27'],
                month    => ['3', '6', '9', '12'],
            }

        cron { 'update_statistics':
            ensure   => present,
            command  => "/usr/local/bin/foreachwikiindblist /srv/mediawiki/cache/databases-wikitide.json ${runner}/srv/mediawiki/${version}/maintenance/initSiteStats.php --update --active > /dev/null",
            user     => 'www-data',
            minute   => '0',
            hour     => '5',
            monthday => [ '1', '15' ],
        }

        cron { 'update_sites':
            ensure   => present,
            command  => "/usr/local/bin/foreachwikiindblist /srv/mediawiki/cache/databases-wikitide.json ${runner}/srv/mediawiki/${version}/extensions/WikiTideMagic/maintenance/populateWikibaseSitesTable.php > /dev/null",
            user     => 'www-data',
            minute   => '0',
            hour     => '5',
            monthday => [ '5', '20' ],
        }

        cron { 'clean_gu_cache':
            ensure   => present,
            command  => "/usr/local/bin/foreachwikiindblist /srv/mediawiki/cache/databases-wikitide.json ${runner}/srv/mediawiki/${version}/extensions/GlobalUsage/maintenance/refreshGlobalimagelinks.php --pages=existing,nonexisting > /dev/null",
            user     => 'www-data',
            minute   => '0',
            hour     => '5',
            monthday => [ '6', '21' ],
        }
    }

    monitoring::nrpe { 'JobRunner Service':
        command => '/usr/lib/nagios/plugins/check_procs -a redisJobRunnerService -c 1:1',
        docs    => 'https://meta.wikitide.org/wiki/Tech:Icinga/MediaWiki_Monitoring#JobRunner_Service'
    }
}
