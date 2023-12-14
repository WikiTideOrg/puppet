# SPDX-License-Identifier: Apache-2.0
# Generate the html for a wt-style error page
function mediawiki::errorpage_content(Optional[Mediawiki::Errorpage::Options] $options) >> String {
    $defaults = {
        'title'              => 'WikiTide Error',
        'pagetitle'          => 'Error',
        'logo_link'          => 'https://wikitide.org',
        'logo_src'           => '',
        'logo_srcset'        => '',
        'logo_width'         => 135,
        'logo_height'        => 101,
        'logo_alt'           => 'WikiTide',
        'browsersec_comment' => false,
    }
    $errorpage = $defaults.merge($options)
    template('mediawiki/errorpage.html.erb')
}