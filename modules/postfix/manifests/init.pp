# == Class: postfix
#
# Postfix. MTA for local-only or smarthosting.
#
# === Parameters
#
# [*smarthost*]
#   Hostname to relay all mail through. This will also trigger the rewriting
#   of local accounts to a centralised mailing list.
#
#   If set to '' then relaying will be disabled. If set to an array then the
#   first item will be used for `relayhost` and subsequent items, if auth is
#   also enabled, will be used as aliases in sasl_passwd. This is necessary
#   for SES (for example) because the hostname you connect to is a CNAME.
#
#   Default: ''
#
# [*smarthost_user*]
#   User to authenticate all relayed mail with.
#   Default: ''
#
# [*smarthost_pass*]
#   Pass to authenticate all relayed mail with.
#
class postfix (
  $smarthost = undef,
  $smarthost_user = undef,
  $smarthost_pass = undef,
  $rewrite_mail_domain = 'localhost',
  $rewrite_mail_list = 'noemail'
) {

  anchor { 'postfix::begin':
    ensure => absent,
    notify => Class['postfix::service'];
  }
  class { 'postfix::package':
    ensure => absent,
    require => Anchor['postfix::begin'],
    notify  => Class['postfix::service'];
  }
  class { 'postfix::config':
    ensure => absent,
    smarthost           => $smarthost,
    smarthost_user      => $smarthost_user,
    smarthost_pass      => $smarthost_pass,
    rewrite_mail_domain => $rewrite_mail_domain,
    rewrite_mail_list   => $rewrite_mail_list,
    require             => Class['postfix::package'],
    notify              => Class['postfix::service'];
  }
  class { 'postfix::service':
    ensure => absent,
  }
  anchor { 'postfix::end':
    ensure => absent,
    require => Class['postfix::service'],
  }

}
