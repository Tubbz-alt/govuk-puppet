# == Class: govuk_sysdig
#
# Manage the sysdig package and repository
#
# === Parameters
#
# [*apt_mirror_hostname*]
#   Hostname to use for the APT mirror.
#   Defaults to undefined because `$use_mirror` can be disabled.
#
class govuk_sysdig (
  $ensure = 'present',
  $apt_mirror_hostname = "%{hiera('apt_mirror_hostname')}",
) {

  apt::source { 'sysdig':
    ensure   => $ensure,
    location => "http://${apt_mirror_hostname}/sysdig",
    release  => 'stable-amd64',
    key      => 'D27A72F32D867DF9300A241574490FD6EC51E8C4',
  }

  ensure_packages( [ "linux-headers-${::kernelrelease}" ])

  package { 'sysdig':
    ensure  => $ensure,
    require => [
      Apt::Source['sysdig'],
      Package["linux-headers-${::kernelrelease}"],
    ],
  }

}
