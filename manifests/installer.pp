class oracle::installer {
  include oracle::params
  include oracle::root_config

  Exec { path => ['/usr/local/sbin', '/usr/sbin', '/sbin', '/usr/local/bin', '/usr/bin', '/bin'] }

  if ($oracle::oracleVersion == '11')
  {
    $package1='linux.x64_11gR2_database_1of2.zip'
    $package2='linux.x64_11gR2_database_2of2.zip'
  }
  if ($oracle::oracleVersion == '12')
  {
    $package1='linuxamd64_12c_database_1of2.zip'
    $package2='linuxamd64_12c_database_2of2.zip'
  }

	Class['oracle::root_config'] ->

  file {'/app/oracle/install':
    owner => 'oracle',
    group => 'oinstall',
    mode => '0770',
    ensure => directory,
  } ->

  exec {'unzip_installer':
    command => "unzip -o ${oracle::installFiles}/$package1 -d /app/oracle/install; unzip -o ${oracle::installFiles}/$package2 -d /app/oracle/install",
    cwd => $oracle::installFiles,
    user => 'oracle',
    group => 'oinstall',
    creates => '/app/oracle/install/database',
    provider => 'shell',
  } ->

  file {'/app/oracle/install/db_install.rsp':
    owner => 'oracle',
    group => 'oinstall',
    mode => '0640',
    content => template("oracle/$oracle::oracleVersion/db_install.rsp"),
  } ->

  exec {'install_oracle':
    command => '/app/oracle/install/database/runInstaller -silent -ignoreSysPrereqs -ignorePrereq -noconfig -waitforcompletion -responseFile /app/oracle/install/db_install.rsp',
    cwd => '/app/oracle/install/database',
    user => 'oracle',
    group => 'oinstall',
    creates => "/app/oracle/local/product/$oracle::oracleVersion/db_1/root.sh",
    provider => 'shell',
    timeout => 0,
  } ->

  exec {'post_install_root':
    command => "/app/oracle/local/product/$oracle::oracleVersion/db_1/root.sh",
    user => 'root',
    group => 'root',
    provider => 'shell',
  } ->

  exec {"post_install_cleanup":
    command => 'rm -Rf /app/oracle/install/database/*',
    user => 'root',
    group => 'root',
    provider => 'shell',
  }
}
