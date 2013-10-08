class carbon {

 $build_dir = "/tmp"

 $carbon_url = "http://launchpad.net/graphite/0.9/0.9.9/+download/carbon-0.9.9.tar.gz"

 $carbon_loc = "$build_dir/carbon.tar.gz"

 include graphite

  package { "python-twisted" :
    ensure => latest
  }

 file { "/etc/init.d/carbon" :
   source => "/tmp/vagrant-puppet/modules-0/carbon/files/carbon",
   ensure => present,
 }

 file { "/opt/graphite/conf/carbon.conf" :
   source => "/tmp/vagrant-puppet/modules-0/carbon/files/carbon.conf",
   ensure => present,
   notify => Service[carbon],
   subscribe => Exec[install-carbon],
 }

 file { "/opt/graphite/conf/storage-schemas.conf" :
   source => "/tmp/vagrant-puppet/modules-0/carbon/files/storage-schemas.conf",
   ensure => present,
   notify => Service[carbon],
   subscribe => Exec[install-carbon],
 }

 file { "/var/log/carbon" :
   ensure => directory,
   owner => www-data,
   group => www-data,
 }

 service { carbon :
    ensure  => running,
    require => File["/etc/init.d/carbon"]
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

 exec { "install-carbon" :
   command => "python setup.py install",
   cwd => "$build_dir/carbon-0.9.9",
   require => Exec[unpack-carbon],
   creates => "/opt/graphite/bin/carbon-cache.py",
  }
}