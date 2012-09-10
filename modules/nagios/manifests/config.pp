class nagios::config ($platform = $::govuk_platform) {

  $domain = $platform ? {
    'development' => 'dev.gov.uk',
    default       => "${platform}.alphagov.co.uk",
  }

  $vhost = "nagios.${domain}"

  nginx::config::ssl { $vhost: certtype => 'wildcard_alphagov' }
  nginx::config::site { $vhost:
    content => template('nagios/nginx.conf.erb'),
  }

  file { '/etc/nagios3':
    ensure  => directory,
    recurse => true,
    source  => 'puppet:///modules/nagios/etc/nagios3',
  }

  file { '/etc/nagios3/conf.d':
    ensure  => directory,
    purge   => true,
    force   => true,
    recurse => true,
    source  => 'puppet:///modules/nagios/etc/nagios3/conf.d',
  }

  @@nagios::check { 'check_smokey':
    check_command       => 'run_smokey_tests',
    service_description => 'Run small suite of functional tests',
    host_name           => "${::govuk_class}-${::hostname}"
  }

  @@nagios::check { 'check_pingdom':
    check_command       => 'run_pingdom_homepage_check',
    service_description => 'Check the current pingdom status',
    host_name           => "${::govuk_class}-${::hostname}"
  }

  nagios::timeperiod { '24x7':
    timeperiod_alias => '24 Hours A Day, 7 Days A Week',
    sun              => '00:00-24:00',
    mon              => '00:00-24:00',
    tue              => '00:00-24:00',
    wed              => '00:00-24:00',
    thu              => '00:00-24:00',
    fri              => '00:00-24:00',
    sat              => '00:00-24:00',
  }

  nagios::timeperiod { 'workhours':
    timeperiod_alias => 'Standard Work Hours',
    mon              => '09:00-17:00',
    tue              => '09:00-17:00',
    wed              => '09:00-17:00',
    thu              => '09:00-17:00',
    fri              => '09:00-17:00',
  }

  nagios::timeperiod { 'nonworkhours':
    timeperiod_alias => 'Non-Work Hours',
    sun              => '00:00-24:00',
    mon              => '00:00-09:00,16:00-24:00',
    tue              => '00:00-09:00,16:00-24:00',
    wed              => '00:00-09:00,16:00-24:00',
    thu              => '00:00-09:00,16:00-24:00',
    fri              => '00:00-09:00,17:00-24:00',
    sat              => '00:00-24:00',
  }

  nagios::timeperiod { 'never':
    timeperiod_alias => 'Never'
  }

  #TODO: extlookup or hiera for email addresses?

  case $::govuk_provider {
    sky: {
      $contact_email = $::govuk_platform ? {
        production   => 'monitoring-skyprod@digital.cabinet-office.gov.uk',
        default      => 'root@localhost',
      }
    }
    default: {
      $contact_email = $::govuk_platform ? {
        production   => 'monitoring-ec2production@digital.cabinet-office.gov.uk',
        preview      => 'monitoring-ec2preview@digital.cabinet-office.gov.uk',
        default      => 'root@localhost',
      }
    }
  }

  nagios::contact { 'monitoring_google_group':
    email => $contact_email
  }

  nagios::pager_contact { 'pager_nonworkhours':
    service_notification_options => 'c',
    notification_period          => 'nonworkhours',
  }

  nagios::contact_group { 'emergencies':
    group_alias => 'Contacts for emergency situations',
    members     => ['monitoring_google_group','pager_nonworkhours'],
  }

  nagios::contact_group { 'regular':
    group_alias => 'Contacts for regular alerts',
    members     => ['monitoring_google_group'],
  }

  nagios::service_template { 'govuk_emergency_service':
    contact_groups => ['emergencies']
  }

  nagios::service_template { 'govuk_regular_service':
    contact_groups => ['regular']
  }

  case $::govuk_provider {
    sky: {
      $monitoring_url = $::govuk_platform ? {
        production    => 'http://skyscape-monitoring/nagios3/',
        default       => 'http://skyscape-monitoring/nagios3/',
      }
    }
    default: {
      $monitoring_url = $::govuk_platform ? {
        production    => 'http://monitoring.production.alphagov.co.uk/nagios3/',
        preview       => 'http://monitoring.preview.alphagov.co.uk/nagios3/',
        default       => 'http://localhost/nagios3/',
      }
    }
  }

  file { '/etc/nagios3/resource.cfg':
    content  => template('nagios/resource.cfg.erb'),
  }

  cron { 'pagerduty':
    command => '/usr/local/bin/pagerduty_nagios.pl flush',
    user    => 'nagios',
    minute  => '*',
  }

  user { 'www-data':
    groups => ['nagios'],
  }

}
