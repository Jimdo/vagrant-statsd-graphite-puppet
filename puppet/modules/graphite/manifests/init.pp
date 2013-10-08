class graphite {

 $build_dir = "/tmp"

 $webapp_url = "http://launchpad.net/graphite/0.9/0.9.9/+download/graphite-web-0.9.9.tar.gz"

 $webapp_loc = "$build_dir/graphite-web.tar.gz"

  exec { "download-graphite-webapp":
        command => "wget -O $webapp_loc $webapp_url",
        creates => "$webapp_loc"
   }

   exec { "unpack-webapp":
     command => "tar -zxvf $webapp_loc",
     cwd => $build_dir,
     subscribe=> Exec[download-graphite-webapp],
     refreshonly => true,
   }

   exec { "install-webapp":
     command => "python setup.py install",
     cwd => "$build_dir/graphite-web-0.9.9",
     require => Exec[unpack-webapp],
     creates => "/opt/graphite/webapp"
   }

  file { [ "/opt/graphite/storage", "/opt/graphite/storage/whisper" ]:
    owner => "www-data",
    subscribe => Exec["install-webapp"],
    mode => "0775",
  }

  exec { "init-db":
     command => "python manage.py syncdb --noinput",
     cwd => "/opt/graphite/webapp/graphite",
     creates => "/opt/graphite/storage/graphite.db",
     subscribe => File["/opt/graphite/storage"],
     require => [ File["/opt/graphite/webapp/graphite/initial_data.json"], Package["python-django-tagging"] ]
   }

  file { "/opt/graphite/webapp/graphite/initial_data.json" :
     require => File["/opt/graphite/storage"],
     ensure => present,
     content => '
[
  {
    "pk": 1, 
    "model": "auth.user", 
    "fields": {
      "username": "admin", 
      "first_name": "", 
      "last_name": "", 
      "is_active": true, 
      "is_superuser": true, 
      "is_staff": true, 
      "last_login": "2011-09-20 17:02:14", 
      "groups": [], 
      "user_permissions": [], 
      "password": "sha1$1b11b$edeb0a67a9622f1f2cfeabf9188a711f5ac7d236", 
      "email": "root@example.com", 
      "date_joined": "2011-09-20 17:02:14"
    }
  }
]'
  }

  file { "/opt/graphite/storage/graphite.db" :
    owner => "www-data",
    mode => "0664",
    subscribe => Exec["init-db"],
    notify => Service["apache2"],
  }

  file { "/opt/graphite/storage/log/webapp/":
    ensure => "directory",
    owner => "www-data",
    mode => "0775",
    subscribe => Exec["install-webapp"],
  }

  file { "/opt/graphite/webapp/graphite/local_settings.py" :
    source => "/tmp/vagrant-puppet/modules-0/graphite/files/local_settings.py",
    ensure => present,
    require => File["/opt/graphite/storage"]
 }

  file { "/etc/apache2/sites-available/default" :
    content =>' 
<VirtualHost *:80>
        ServerName graphite
        DocumentRoot "/opt/graphite/webapp"
        ErrorLog /opt/graphite/storage/log/webapp/error.log
        CustomLog /opt/graphite/storage/log/webapp/access.log common

        <Location "/">
                SetHandler python-program
                PythonPath "[\'/opt/graphite/webapp\'] + sys.path"
                PythonHandler django.core.handlers.modpython
                SetEnv DJANGO_SETTINGS_MODULE graphite.settings
                PythonDebug Off
                PythonAutoReload Off
        </Location>

        <Location "/content/">
                SetHandler None
        </Location>

        <Location "/media/">
                SetHandler None
        </Location>

    # NOTE: In order for the django admin site media to work you
    # must change @DJANGO_ROOT@ to be the path to your django
    # installation, which is probably something like:
    # /usr/lib/python2.6/site-packages/django
        Alias /media/ "@DJANGO_ROOT@/contrib/admin/media/"

</VirtualHost>',
    notify => Service["apache2"],
    require => Package["apache2"],
  }

  service { "apache2" :
    ensure => "running",
    require => [ File["/opt/graphite/storage/log/webapp/"], File["/opt/graphite/storage/graphite.db"] ],
  }

  package {
        [ apache2, python-ldap, python-cairo, python-django, python-django-tagging, python-simplejson, libapache2-mod-python, python-memcache, python-pysqlite2]: ensure => latest;
  }

  package {
    python-whisper :
      ensure   => installed,
      provider => dpkg,
      source   => "/vagrant/python-whisper_0.9.9-1_all.deb",
      require  => Package['python-support']
  }

  package { "python-support":
    ensure => installed,
  }

}
