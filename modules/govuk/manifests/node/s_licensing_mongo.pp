# == Class: govuk::node::s_licensing_mongo
#
# mongo node
#
class govuk::node::s_licensing_mongo inherits govuk::node::s_base {
  include mongodb::server
  include govuk_env_sync

  collectd::plugin::tcpconn { 'mongo':
    incoming => 27017,
    outgoing => 27017,
  }

  Govuk_mount['/var/lib/mongodb'] -> Class['mongodb::server']
  Govuk_mount['/var/lib/s3backup'] -> Class['mongodb::backup']
}
