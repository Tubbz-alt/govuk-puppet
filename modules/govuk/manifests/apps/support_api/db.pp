# == Class: govuk::apps::support_api::db
#
# GOV.UK specific class to configure a PostgreSQL instance to store
# anonymous feedback data.
#
# === Parameters
#
# [*password*]
#   The DB instance password.
#
# [*backend_ip_range*]
#   Backend IP addresses to allow access to the database.
#
# [*allow_auth_from_lb*]
#   Whether to allow this user to authenticate for this database from
#   the load balancer using its password.
#   Default: false
#
# [*lb_ip_range*]
#   Network range for the load balancer.
#
class govuk::apps::support_api::db (
  $password,
  $backend_ip_range = '10.3.0.0/16',
  $allow_auth_from_lb = false,
  $lb_ip_range = undef,
  $rds = false,
) {

  govuk_postgresql::db { 'support_contacts_production':
    user                    => 'support_contacts',
    password                => $password,
    allow_auth_from_backend => true,
    backend_ip_range        => $backend_ip_range,
    allow_auth_from_lb      => $allow_auth_from_lb,
    lb_ip_range             => $lb_ip_range,
    rds                     => $rds,
  }
}
