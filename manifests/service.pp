# == Class: solr::service
# This class sets up solr service
#
# Via jetty if SOLR version <5 and Ubuntu 16.04 and lower
# otherwise sets up solr service
class solr::service (
  $jetty_package = $solr::params::jetty_package,
){

  if versioncmp($::solr::version, '5.0') < 0 {

    if versioncmp($facts['os']['release']['full'], '18') >= 0 {

      service { 'solr':
        ensure   => running,
        provider => systemd,
      }

    } else {
      service { $jetty_package:
        ensure     => running,
        hasrestart => true,
        hasstatus  => true,
        require    => Package[$jetty_package],
      }
    }
  } else {
    # SOLR 5.x and up
    service { 'solr':
      ensure     => running,
      hasrestart => true,
      hasstatus  => true,
      require    => Exec['install-solr'],
    }
  }
}
