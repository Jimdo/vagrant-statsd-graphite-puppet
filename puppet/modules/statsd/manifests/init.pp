class statsd {

   package { "nodejs" :
     ensure => "present"
   }

   package { "statsd" :
     provider => "dpkg",
     source => "/vagrant/statsd_0.0.1_all.deb",
     ensure => installed,
     require => Package[nodejs],
   }

}