# vim: ts=2 sw=2 et
class splunk::web (
  $ciphersuite = $splunk::ciphersuite,
  $sslversions = $splunk::sslversions,
  $httpport = $splunk::httpport,
  $ecdhcurvename = $splunk::ecdhcurvename,
  $splunk_os_user = $splunk::real_splunk_os_user,
  $splunk_os_group = $splunk::real_splunk_os_group,
  $splunk_dir_mode = $splunk::real_splunk_dir_mode,
  $splunk_file_mode = $splunk::real_splunk_file_mode,
  $splunk_app_precedence_dir = $splunk::splunk_app_precedence_dir,
  $splunk_app_replace = $splunk::splunk_app_replace,
  $splunk_home = $splunk::splunk_home
){
  $splunk_app_name = 'puppet_common_ssl_web'
  if $httpport == undef {
    file {"${splunk_home}/etc/apps/${splunk_app_name}_base":
      ensure  => absent,
      recurse => true,
      purge   => true,
      force   => true,
    }
    -> file { ["${splunk_home}/etc/apps/${splunk_app_name}_disabled",
            "${splunk_home}/etc/apps/${splunk_app_name}_disabled/${splunk_app_precedence_dir}",
            "${splunk_home}/etc/apps/${splunk_app_name}_disabled/metadata",]:
      ensure => directory,
      owner  => $splunk_os_user,
      group  => $splunk_os_group,
      mode   => $splunk_dir_mode,
    }
    -> file { "${splunk_home}/etc/apps/${splunk_app_name}_disabled/${splunk_app_precedence_dir}/web.conf":
      ensure  => present,
      owner   => $splunk_os_user,
      group   => $splunk_os_group,
      mode    => $splunk_file_mode,
      replace => $splunk_app_replace,
      content => template("splunk/${splunk_app_name}_base/local/web.conf"),
    }
  } else {
    case $::osfamily {
      /^[Ww]indows$/: {
        # On Windows, we have to run createssl ourselves because we run the msi with LAUNCHSPLUNK=0
        exec { 'splunk createssl':
          command     => 'splunk createssl web-cert 2048',
          path        => ["${splunk_home}/bin"],
          environment => "OPENSSL_CONF=${splunk_home}/openssl.cnf",
          creates     => [
            "${splunk_home}/etc/auth/splunkweb/cert.pem",
          ],
          logoutput   => true,
        }
      }
      default: {
        # On Linux this already taken care of by enable boot-start
      }
    }
    file {"${splunk_home}/etc/apps/${splunk_app_name}_disabled":
      ensure  => absent,
      recurse => true,
      purge   => true,
      force   => true,
    }
    -> file { ["${splunk_home}/etc/apps/${splunk_app_name}_base",
            "${splunk_home}/etc/apps/${splunk_app_name}_base/${splunk_app_precedence_dir}",
            "${splunk_home}/etc/apps/${splunk_app_name}_base/metadata",]:
      ensure => directory,
      owner  => $splunk_os_user,
      group  => $splunk_os_group,
      mode   => $splunk_dir_mode,
    }
    -> file { "${splunk_home}/etc/apps/${splunk_app_name}_base/${splunk_app_precedence_dir}/web.conf":
      ensure  => present,
      owner   => $splunk_os_user,
      group   => $splunk_os_group,
      mode    => $splunk_file_mode,
      replace => $splunk_app_replace,
      content => template("splunk/${splunk_app_name}_base/local/web.conf"),
    }

  }
}
