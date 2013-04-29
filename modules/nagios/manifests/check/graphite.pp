# == Define: nagios::check::graphite
#
# Wrapper for `nagios::check` that references `check_graphite` and creates
# an alert with the appropriate `graph_url` link containing warning and
# critical bands.
#
# It is deliberately quite simple and doesn't take many arguments, which
# will result in the defaults from `nagios::check`. It can be extended as
# necessary.
#
# === Parameters
#
# [*target*]
#   Graphite expression that will return a single metric. See:
#   http://graphite.readthedocs.org/en/1.0/url-api.html#target
#   This metric will be summarized over the last 5 minutes using the graphite
#   summarize function to average the values.
#
# [*desc*]
#   Description of the Nagios alert. Will be passed to the `nagios::check`
#   param `service_description`.
#
# [*warning*]
#   Integer that will raise a warning alert.
#
# [*critical*]
#   Integer that will raise a critical alert.
#
# [*host_name*]
#   Passed to `nagios::check` as `host_name`. Usually `$::fqdn`.
#
#   This is a mandatory argument because the type is typically used as an
#   exported resource. In which case the variable must be eagerly evaluated
#   when passed by the exporting node, rather than lazily evaluated inside
#   the define by the collecting node.
#
# [*summary_function*]
#   Used to pass to graphites summary function, for the type of summary over
#   5mins.
#
#  It defaults to avg. Options that can be passed are: 'avg', 'max', 'min', and 'last'.
#  For more details refer to graphite.readthedocs.org/en/0.9.10/functions.html summarize
#  section.
#
# [*args*]
#   Single string of additional arguments passed to `check_graphite`. This
#   will trigger the use of `check_graphite_metric_args` instead of
#   `check_graphite_metric`.
#   Default: ''
#
#
define nagios::check::graphite(
  $target,
  $desc,
  $warning,
  $critical,
  $host_name,
  $args = undef,
  $document_url = '',
  $summary_function = 'avg'
) {
  $check_command = $args ? {
    undef   => 'check_graphite_metric',
    default => 'check_graphite_metric_args',
  }
  $target_real = "summarize(${target},\"5minutes\",\"${summary_function}\",true)"
  $args_real = $args ? {
    undef   => '',
    default => "!${args}",
  }

  $monitoring_domain_suffix = extlookup("monitoring_domain_suffix", "")
  $graph_width = 600
  $graph_height = 300

  nagios::check { $title:
    check_command              => "${check_command}!${target_real}!${warning}!${critical}${args_real}",
    service_description        => $desc,
    host_name                  => $host_name,
    graph_url                  => "https://graphite.${monitoring_domain_suffix}/render/?\
width=${graph_width}&height=${graph_height}&\
target=${target}&\
target=alias(dashed(constantLine(${warning})),\"warning\")&\
target=alias(dashed(constantLine(${critical})),\"critical\")",
    document_url               => $document_url,
    attempts_before_hard_state => 1,
  }
}
