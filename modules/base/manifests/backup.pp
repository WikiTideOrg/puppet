# class base::backup
class base::backup (
    String $pca_password = lookup('private::passwords::pca')
) {
    stdlib::ensure_packages(['python3-fabric', 'python3-decorator'])

    file { '/usr/local/bin/wikitide-backup':
        mode    => '0555',
        content => template('base/backups/wikitide-backup.py.erb'),
    }
}
