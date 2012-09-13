class govuk_node::efg_mysql_master_server inherits govuk_node::base {
  $root_password = extlookup('mysql_root', '')
  $replica_password = extlookup('mysql_replica_password', '')
  $master_server_id = '1'

  class { 'mysql::server':
    root_password => $root_password,
    server_id     => $master_server_id
  }

  # TODO: PP 2012-08-17: push replica_user into mysql::server
  class {'mysql::server::replica_user':
    host           => 'localhost',
    root_password  => $root_password,
    password       => $replica_password,
  }

  class {'govuk::apps::efg::db':
    require => Class['mysql::server']
  }
}
