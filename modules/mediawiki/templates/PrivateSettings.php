<?php

// Database passwords
$wgDBadminpassword = '<%= @wikiadmin_password %>';
$wgDBpassword = '<%= @mediawiki_password %>';

// Extension:DiscordNotifications global webhook
$wmgGlobalDiscordWebhookUrl = '<%= @global_discord_webhook_url %>';
$wmgDiscordExperimentalWebhook = '<%= @discord_experimental_webhook %>';

// hCaptcha secret key
$wgHCaptchaSecretKey = '<%= @hcaptcha_secretkey %>';

// LDAP 'write-user' password
$wmgLdapPassword = "<%= @ldap_password %>";

// Swift password for mw
$wmgSwiftPassword = "<%= @swift_password %>";

// MediaWiki secret keys
$wgUpgradeKey = '<%= @mediawiki_upgradekey %>';
$wgSecretKey = '<%= @mediawiki_secretkey %>';

// Noreply authentication
$wmgSMTPPassword = '<%= @noreply_password %>';

// Redis AUTH password
$wmgRedisPassword = '<%= @redis_password %>';

// Shellbox secret key
$wgShellboxSecretKey = '<%= @shellbox_secretkey %>';

// Matomo token
$wgMatomoAnalyticsTokenAuth = "<%= @matomotoken %>";

// Miscellaneous

// External Data credentials for cslmodswikitide
$wmgExternalDataCredsCslmodswikitide = '<%= @mediawiki_externaldata_cslmodswikitide %>';
