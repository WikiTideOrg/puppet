#!/usr/bin/env php
<?php

error_reporting( 0 );

require_once '/srv/mediawiki/config/initialize/WikiTideFunctions.php';

if ( ( $argv[1] ?? false ) === 'all' ) {
	echo json_encode( WikiTideFunctions::MEDIAWIKI_VERSIONS );
	exit( 0 );
}

$versions = array_unique( WikiTideFunctions::MEDIAWIKI_VERSIONS );
asort( $versions );

echo json_encode( array_combine( $versions, $versions ) );
