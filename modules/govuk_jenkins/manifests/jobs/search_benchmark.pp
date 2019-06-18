# == Class: govuk_jenkins::jobs::search_benchmark
#
# Create a file on disk that can be parsed by jenkins-job-builder
#
class govuk_jenkins::jobs::search_benchmark (
  $auth_username = undef,
  $auth_password = undef,
  $rate_limit_token = undef,
  $cron_schedule = '30 4 * * *'
) {

  if $::aws_migration {
    $app_domain = hiera('app_domain_internal')
  } else {
    $app_domain = hiera('app_domain')
  }

  $test_type = 'results'
  $job_name = 'search_benchmark'
  $service_description = 'Benchmark search queries'
  $job_url = "https://deploy.${app_domain}/job/search_benchmark/"

  file { '/etc/jenkins_jobs/jobs/search_benchmark.yaml':
    ensure  => present,
    content => template('govuk_jenkins/jobs/benchmark_search.yaml.erb'),
    notify  => Exec['jenkins_jobs_update'],
  }

  @@icinga::passive_check { "${job_name}_${::hostname}":
    service_description => $service_description,
    host_name           => $::fqdn,
    freshness_threshold => 104400,
    action_url          => $job_url,
    notes_url           => monitoring_docs_url(search-benchmarking),
  }
}
