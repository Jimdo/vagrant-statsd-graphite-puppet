class carbon($version = '0.9.12') {

  $build_dir = "/tmp"

  $carbon_url = "https://github.com/graphite-project/carbon/archive/${version}.tar.gz"

  $carbon_loc = "$build_dir/carbon.tar.gz"

  class {'graphite':
    version => $version,
  }

  file { "/etc/init.d/carbon" :
    source => "puppet:///modules/carbon/carbon",
    ensure => present,
  }

  file { "/opt/graphite/conf/carbon.conf" :
    source => "puppet:///modules/carbon/carbon.conf",
    ensure => present,
    notify => Service[carbon],
    subscribe => Exec[install-carbon],
  }

  file { "/opt/graphite/conf/storage-schemas.conf" :
    source => "puppet:///modules/carbon/storage-schemas.conf",
    ensure => present,
    notify => Service[carbon],
    subscribe => Exec[install-carbon],
  }

  file { "/var/log/carbon" :
    ensure => directory,
    owner => www-data,
    group => www-data,
  }

  exec { "download-graphite-carbon":
    command => "wget -O $carbon_loc $carbon_url",
    creates => "$carbon_loc"
  }

  exec { "unpack-carbon":
    command => "tar -zxvf $carbon_loc",
    cwd => $build_dir,
    subscribe => Exec[download-graphite-carbon],
    refreshonly => true,
  }

  # Downgrade Twisted to v12 for graohite
  package{['python-dev','python-pip']:
    require => Anchor['graphite::end'],
  } ->
  exec {'/usr/bin/pip install \'Twisted<12.0\' --upgrade':} ->
  exec { "install-carbon" :
    command => "python setup.py install",
    cwd => "$build_dir/carbon-${version}",
    require => Exec[unpack-carbon],
    creates => "/opt/graphite/bin/carbon-cache.py"
  }

  service { carbon :
    ensure  => running,
    enable  => true,
    require => [Exec['install-carbon']]
  }

}
