# FIXME: This class needs better documentation as per https://docs.puppetlabs.com/guides/style_guide.html#puppet-doc
class govuk::apps::frontend(
  $port = 3005,
  $enable_homepage_nocache_location = true,
  $vhost_protected = false,
) {
  validate_bool($enable_homepage_nocache_location)

  if ($enable_homepage_nocache_location) {
    $nginx_extra_config = '
  location ^~ /frontend/homepage/no-cache/ {
    expires epoch;
  }
'
  } else {
    $nginx_extra_config = ''
  }

  govuk::app { 'frontend':
    app_type              => 'rack',
    port                  => $port,
    vhost_aliases         => ['private-frontend'],
    vhost_protected       => $vhost_protected,
    health_check_path     => '/',
    log_format_is_json    => true,
    asset_pipeline        => true,
    asset_pipeline_prefix => 'frontend',
    nginx_extra_config    => $nginx_extra_config,
  }
}
