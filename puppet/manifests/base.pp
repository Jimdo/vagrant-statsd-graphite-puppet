Exec {
    path => ["/usr/bin", "/usr/sbin", '/bin']
}

Exec["apt-get-update"] -> Package <| |>

exec { "apt-get-update" :
    command => "/usr/bin/apt-get update",
    require => File["/etc/apt/preferences"]
}

file { "/etc/apt/preferences" :
    content => "
Package: *
Pin: release a=stable
Pin-Priority: 800

Package: *
Pin: release a=testing
Pin-Priority: 750

Package: *
Pin: release a=unstable
Pin-Priority: 650

Package: *
Pin: release a=oldstable
Pin-Priority: 600

Package: *
Pin: release a=experimental
Pin-Priority: 550
",
    ensure => present,
}

include carbon
include statsd
