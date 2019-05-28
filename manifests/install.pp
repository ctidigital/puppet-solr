# == Class: solr::install
# This class installs the required packages for jetty
#
# === Actions
# - Installs default jdk
# - Installs jetty and extra libs
#

class solr::install {

  ensure_packages(['software-properties-common'])

  if ! defined(Package['oracle-java8-set-default']) {
    package { 'oracle-java8-set-default':
      ensure => purged,
      before => Exec['Remove_Oracle_Java_PPA'],
    }
  }

  if ! defined(Package['oracle-java8-installer']) {
    package { 'oracle-java8-installer':
      ensure => purged,
      before => Exec['Remove_Oracle_Java_PPA'],
    }
  }

  exec { 'Remove_Oracle_Java_PPA':
    path    => [ '/bin', '/sbin' , '/usr/bin', '/usr/sbin', '/usr/local/bin' ],
    command => 'add-apt-repository -y --remove ppa:webupd8team/java; apt-get -y update',
    onlyif  => "test -s /etc/apt/sources.list.d/webupd8team-ubuntu-java-${::lsbdistcodename}.list",
  }


  if versioncmp($facts['os']['release']['full'], '14') == 0 {
    if ! defined(Package['default-jdk']) {
      package { 'default-jdk':
      ensure    => present,
      }
    }

    if ! defined(Package['jetty']) {
      package { 'jetty':
        ensure  => present,
        require => Package['default-jdk'],
      }
    }

    if ! defined(Package['libjetty-extra']) {
      package { 'libjetty-extra':
        ensure  => present,
        require => Package['jetty'],
      }
    }
  }

  if versioncmp($facts['os']['release']['full'], '16') == 0 {
    exec { 'Add_OpenJDK_Repo':
      path    => [ '/bin', '/sbin' , '/usr/bin', '/usr/sbin', '/usr/local/bin' ],
      command => 'add-apt-repository -y ppa:openjdk-r/ppa; apt-get -y update',
      creates => "/etc/apt/sources.list.d/openjdk-r-ubuntu-ppa-${::lsbdistcodename}.list",
    }

    if versioncmp($::solr::version, '4.0') >= 0 {
      $java_package='openjdk-8-jdk-headless'
    } else {
      $java_package='openjdk-7-jre-headless'
    }

    if ! defined(Package[$java_package]) {
      package { $java_package:
        ensure  => present,
        require => Exec['Add_OpenJDK_Repo'],
      }
    }

    if versioncmp($::solr::version, '5.0') < 0 {

      if ! defined(Package['jetty8']) {
        package { 'jetty8':
          ensure  => present,
          require => Package[$java_package],
        }
      }

      if ! defined(Package['libjetty8-extra-java']) {
        package { 'libjetty8-extra-java':
          ensure  => present,
          require => Package[$java_package],
        }
      }

      file { '/etc/init.d/jetty8':
        ensure  => present,
        group   => root,
        owner   => root,
        mode    => '0755',
        replace => yes,
        source  => 'puppet:///modules/solr/jetty8',
        require => Package['jetty8'],
      }
    }
  }

  if versioncmp($facts['os']['release']['full'], '18') >= 0 {
    exec { 'Add_OpenJDK_Repo':
      path    => [ '/bin', '/sbin' , '/usr/bin', '/usr/sbin', '/usr/local/bin' ],
      command => 'add-apt-repository -y ppa:openjdk-r/ppa; apt-get -y update',
      creates => "/etc/apt/sources.list.d/openjdk-r-ubuntu-ppa-${::lsbdistcodename}.list",
    }

    if versioncmp($::solr::version, '4.0') >= 0 {
      $java_package='openjdk-8-jdk-headless'
    } else {
      $java_package='openjdk-7-jre-headless'
    }

    if ! defined(Package[$java_package]) {
      package { $java_package:
        ensure  => present,
        require => Exec['Add_OpenJDK_Repo'],
      }
    }
  }

  if ! defined(Package['wget']) {
      package { 'wget':
          ensure  => present,
      }
  }

  if ! defined(Package['curl']) {
      package { 'curl':
          ensure  => present,
      }
  }
}
