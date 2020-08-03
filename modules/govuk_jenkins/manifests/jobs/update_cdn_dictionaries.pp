# == Class: govuk_jenkins::jobs::update_cdn_dictionaries
#
# Create a file on disk that can be parsed by jenkins-job-builder
#
class govuk_jenkins::jobs::update_cdn_dictionaries(
  $app_domain = hiera('app_domain'),
  $allow_deploy_to_mirror = true,
  $services = [],
) {

  $environment_variables = $govuk_jenkins::environment_variables
  $slack_team_domain = 'gds'
  $slack_room = 'govuk-deploy'
  $slack_build_server_url = "https://deploy.${app_domain}/"

  file { '/etc/jenkins_jobs/jobs/update_cdn_dictionaries.yaml':
    ensure  => present,
    content => template('govuk_jenkins/jobs/update_cdn_dictionaries.yaml.erb'),
    notify  => Exec['jenkins_jobs_update'],
  }
}
