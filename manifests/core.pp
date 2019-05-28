# == Definition: solr::core
# This definition sets up solr config and data directories for each core
#
# === Parameters
#
# [*core_name*]:: The core to create. Defaults to the title of the resource
# [*config_source*]:: Path to the config source. Defaults to `puppet:///modules/solr/conf`
# [*config_type*]:: Type of the configuration. Possible values are 'directory' or 'link'.
#                   If the config_type is set to `directory`, it will be copied recursivly.
#                   If set to `link`, the config_source will be used as the target.
#
# === Actions
# - Creates the solr web app directory for the core
# - Copies over the config directory for the file
# - Creates the data directory for the core
#
define solr::core(
  $core_name = $title,
  $config_source = 'puppet:///modules/solr/conf',
  $config_type = 'directory',
  $web_group = 'www-data',
) {
  include solr::params


  if versioncmp($::solr::version, '5.0') < 0 {

    if versioncmp($facts['os']['release']['full'], '18') >= 0 {

      $solr_home = "/opt/solr-${::solr::version}"

      file { "${solr_home}/solr/${core_name}":
        ensure  => directory,
        owner   => 'solr',
        group   => 'solr',
        require => Exec['copy-solr4'],
      }

      file { "${solr_home}/solr/${core_name}/core.properties":
        ensure  => file,
        owner   => 'solr',
        group   => 'solr',
        content => "name=${core_name}\n",
        require => File["${solr_home}/solr/${core_name}"],
        notify  => Service['solr'],
      }

      case $config_type {
        'directory': {
          #Copy its config over
          file { "${solr_home}/solr/${core_name}/conf":
            ensure  => directory,
            owner   => 'solr',
            group   => 'solr',
            recurse => true,
            source  => $config_source,
            require => File["${solr_home}/solr/${core_name}"],
            notify  => Service['solr'],
          }
        }

        'link': {
          # Link the config directory
          file {"${solr_home}/solr/${core_name}/conf":
            ensure  => 'link',
            force   => true,
            owner   => 'solr',
            group   => 'solr',
            target  => $config_source,
            require => File["${solr_home}/solr/${core_name}"],
            notify  => Service['solr'],
          }
        }

        default: {
          fail('Unsupported value for parameter config_type')
        }
      }

      file { "${solr_home}/solr/${core_name}/data":
        ensure  => directory,
        owner   => 'solr',
        group   => 'solr',
        require => File["${solr_home}/solr/${core_name}"],
        notify  => Service['solr'],
      }
    } else {

      $solr_home  = $solr::params::solr_home

      file { "${solr_home}/${core_name}":
        ensure  => directory,
        owner   => 'jetty',
        group   => 'jetty',
        require => File[$solr_home],
      }

      case $config_type {
        'directory': {
          #Copy its config over
          file { "${solr_home}/${core_name}/conf":
            ensure  => directory,
            owner   => 'jetty',
            group   => 'jetty',
            recurse => true,
            source  => $config_source,
            require => File["${solr_home}/${core_name}"],
          }
        }

        'link': {
          # Link the config directory
          file {"${solr_home}/${core_name}/conf":
            ensure  => 'link',
            force   => true,
            owner   => 'jetty',
            group   => 'jetty',
            target  => $config_source,
            require => File["${solr_home}/${core_name}"],
          }
        }

        default: {
          fail('Unsupported value for parameter config_type')
        }
      }

      #Finally, create the data directory where solr stores
      #its indexes with proper directory ownership/permissions.
      file { "/var/lib/solr/${core_name}":
        ensure  => directory,
        mode    => '2770',
        owner   => 'jetty',
        group   => 'jetty',
        require => File["${solr_home}/${core_name}/conf"],
      }
    }
  } elsif versioncmp($::solr::version, '7.0') < 0 {
    ## SOLR 5 and 6 core install section
    file { "/var/lib/solr/data/${core_name}":
      ensure => directory,
      mode   => '2770',
      owner  => 'solr',
      group  => 'solr',
    }
    case $config_type {
      'directory': {
        #Copy its config over
        file { "/var/lib/solr/data/${core_name}/conf":
          ensure  => directory,
          owner   => 'solr',
          group   => 'solr',
          recurse => true,
          source  => $config_source,
          require => File["/var/lib/solr/data/${core_name}"],
        }
      }
      'link': {
        # Link the config directory
        file {"/var/lib/solr/data/${core_name}/conf":
          ensure  => 'link',
          force   => true,
          owner   => 'solr',
          group   => 'solr',
          target  => $config_source,
          require => File["/var/lib/solr/data/${core_name}"],
        }
      }
      default: {
        fail('Unsupported value for parameter config_type')
      }
    }

    exec { "create-solr-core-${name}":
      path    => [ '/bin', '/sbin' , '/usr/bin', '/usr/sbin', '/usr/local/bin' ],
      command => "curl 'http://localhost:8983/solr/admin/cores?action=CREATE&name=${core_name}&instanceDir=${core_name}'",
      creates => "/var/lib/solr/data/${core_name}/core.properties",
      require => [File["/var/lib/solr/data/${core_name}/conf"],Exec['Add-solr-to-web-group']],
    }
  }
}
