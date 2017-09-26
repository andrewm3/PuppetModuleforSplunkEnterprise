# vim: ts=2 sw=2 et

class splunk::server::kvstore (
  $kvstoreport = $splunk::kvstoreport,
  $splunk_os_user = $splunk::real_splunk_os_user,
  $splunk_os_group = $splunk::real_splunk_os_group,
  $splunk_dir_mode = $splunk::real_splunk_dir_mode,
  $splunk_file_mode = $splunk::real_splunk_file_mode,
  $splunk_home = $splunk::splunk_home,
  $splunk_app_precedence_dir = $splunk::splunk_app_precedence_dir,
  $splunk_app_replace = $splunk::splunk_app_replace
){
  $splunk_app_name = 'puppet_common_kvstore'
  if $kvstoreport == undef {
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
    -> file { "${splunk_home}/etc/apps/${splunk_app_name}_disabled/${splunk_app_precedence_dir}/server.conf":
      ensure  => present,
      owner   => $splunk_os_user,
      group   => $splunk_os_group,
      mode    => $splunk_file_mode,
      replace => $splunk_app_replace,
      # re-use the _base template, but created on the client as _disabled
      content => template("splunk/${splunk_app_name}_base/local/server.conf"),
    }
  } else {
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
    -> file { "${splunk_home}/etc/apps/${splunk_app_name}_base/${splunk_app_precedence_dir}/server.conf":
      ensure  => present,
      owner   => $splunk_os_user,
      group   => $splunk_os_group,
      mode    => $splunk_file_mode,
      replace => $splunk_app_replace,
      content => template("splunk/${splunk_app_name}_base/local/server.conf"),
    }

  }
}

