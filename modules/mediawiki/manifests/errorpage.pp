# == Define: mediawiki::errorpage
#
# Creates a file based on the error page template.
#
# === Usage
# mediawiki::errorpage { '/tmp/error-example.html':
#     content => '<p>Example</p>'
# }
#
# === Parameters
#
# [*filepath*]
#   The file path for File resource. (Required)
#
# [*favicon*]
#   URL for favicon. (Use undefined to disable)
#
#   Default: undef
#
# [*doctitle*]
#   HTML Document title.
#
#   Default: 'WikiTide Error'
#
# [*pagetitle*]
#   Page heading.
#
#   Default: 'Error'
#
# [*content*]
#   Main HTML content, after logo and first heading. (Required)
#
#   Default: ''
#
# [*logo_link*]
#   URL for anchor link around logo. (Use undef to omit link.)
#
#   Default: 'https://wikitide.org'
#
# [*logo_src*]
#   URL for logo image.
#
#   Default: ''
#
# [*logo_srcset*]
#   HTML srcset attribute value for logo image.
#
#   Default: ''
#
# [*logo_width*]
#   Width attribute for logo image.
#
#   Default: 135
#
# [*logo_height*]
#   Height attribute for logo image.
#
#   Default: 101
#
# [*logo_alt*]
#   Alternate text for logo image.
#
#   Default: 'WikiTide'
#
# [*footer*]
#   Optional HTML content for the footer. (Use undefined to disable)
#
#   Default: undef
#
define mediawiki::errorpage(
    VMlib::Ensure $ensure = present,
    Stdlib::Unixpath $filepath = $name,
    String $owner = 'root',
    String $group = 'root',
    Stdlib::Filemode $mode = '0444',
    Optional[String] $favicon = undef,
    String $doctitle = 'WikiTide Error',
    String $pagetitle = 'Error',
    Stdlib::Httpurl $logo_link = 'https://wikitide.org',
    String $logo_src = '',
    String $logo_srcset = '',
    Integer $logo_width = 135,
    Integer $logo_height = 101,
    String $logo_alt = 'WikiTide',
    Optional[String] $content = undef,
    Optional[String] $footer = undef,
    Optional[String] $margin = undef,
    Optional[String] $margin_top = undef,
) {
    $errorpage = {
        favicon     => $favicon,
        title       => $doctitle,
        pagetitle   => $pagetitle,
        logo_link   => $logo_link,
        logo_src    => $logo_src,
        logo_srcset => $logo_srcset,
        logo_width  => $logo_width,
        logo_height => $logo_height,
        logo_alt    => $logo_alt,
        content     => $content,
        footer      => $footer,
        margin      => $margin,
        margin_top  => $margin_top,
    }
    file { $filepath:
        ensure  => stdlib::ensure($ensure, 'file'),
        owner   => $owner,
        group   => $group,
        mode    => $mode,
        content => mediawiki::errorpage_content($errorpage),
    }
}