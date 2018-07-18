# == Class: solr::params
# This class sets up some required parameters
#
# === Actions
# - Specifies jetty and solr home directories
# - Specifies the default core
#
class solr::params {

  $solr_home     = '/usr/share/solr'
  $solr_version  = '4.7.2'
  $mirror_site   = 'http://archive.apache.org/dist/lucene/solr'
  $data_dir      = '/var/lib/solr'
  $cores         = ['default']
  $dist_root     = '/tmp'
  $heap_size     = "256m"

  if versioncmp($::solr::version, '4.0') < 0 {
    case $::lsbdistcodename {
      'trusty': {
        $jetty_home    = '/usr/share/jetty'
        $jetty_package = 'jetty'
        $jdk_dirs = '/usr/lib/jvm/default-java /usr/lib/jvm/java-7-openjdk-amd64'
      }

      'xenial': {
        $jetty_home    = '/usr/share/jetty'
        $jetty_package = 'jetty8'
        $jdk_dirs = '/usr/lib/jvm/default-java /usr/lib/jvm/java-7-openjdk-amd64'
      }

      default: {
        $jetty_home    = '/usr/share/jetty8'
        $jetty_package = 'jetty8'
        $jdk_dirs = '/usr/lib/jvm/default-java /usr/lib/jvm/java-7-openjdk-amd64'
      }
    }
  } else {
    case $::lsbdistcodename {
      'trusty': {
        $jetty_home    = '/usr/share/jetty'
        $jetty_package = 'jetty'
        $jdk_dirs = '/usr/lib/jvm/default-java /usr/lib/jvm/java-8-openjdk-amd64'
      }

      'xenial': {
        $jetty_home    = '/usr/share/jetty'
        $jetty_package = 'jetty8'
        $jdk_dirs = '/usr/lib/jvm/default-java /usr/lib/jvm/java-8-openjdk-amd64'
      }

      default: {
        $jetty_home    = '/usr/share/jetty8'
        $jetty_package = 'jetty8'
        $jdk_dirs = '/usr/lib/jvm/default-java /usr/lib/jvm/java-8-openjdk-amd64'
      }
    }
  }
}
