class govuk::apps::publicapi (
  $backdrop_protocol = 'https',
  $backdrop_host = 'www.performance.service.gov.uk',
) {

  $app_domain = hiera('app_domain')

  $privateapi = "contentapi.${app_domain}"
  $whitehallapi = "whitehall-frontend.${app_domain}"
  $factcaveapi = "fact-cave.${app_domain}"
  $business_support_api = "business-support-api.${app_domain}"
  $rummager_api = "search.${app_domain}"

  $backdrop_url = "${backdrop_protocol}://${backdrop_host}"

  $app_name = 'publicapi'
  $full_domain = "${app_name}.${app_domain}"

  nginx::config::vhost::proxy { $full_domain:
    to               => [$privateapi],
    to_ssl           => true,
    protected        => false,
    ssl_only         => false,
    extra_app_config => "
      # Don't proxy_pass / anywhere, just return 404. All real requests will
      # be handled by the location blocks below.
      return 404;
    ",
    extra_config     => template('govuk/publicapi_nginx_extra_config.erb')
  }
}
