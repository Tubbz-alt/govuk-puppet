# == Class: govuk_jenkins::jobs::deploy_licensify
#
# Create a file on disk that can be parsed by jenkins-job-builder
#
# === Parameters
#
# [*ci_deploy_jenkins_api_key*]
#   API key to download build artefacts from CI servers
#
class govuk_jenkins::jobs::deploy_licensify (
  $ci_deploy_jenkins_api_key = undef,
) {
  file { '/etc/jenkins_jobs/jobs/deploy_licensify.yaml':
    ensure  => present,
    content => template('govuk_jenkins/jobs/deploy_licensify.yaml.erb'),
    notify  => Exec['jenkins_jobs_update'],
  }
}
