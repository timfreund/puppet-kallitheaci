# == Class: kallitheaci
#
# Configure CI services for the Kallithea project.
#
# === Parameters
#
# None

# === Variables
#
# None
#
# === Examples
#
#  include kallitheaci
#
# === Authors
#
# Tim Freund <tim@freunds.net>
#
# === Copyright
#
# Copyright 2014 Tim Freund
#
class kallitheaci {
  include jenkins
  
  jenkins::plugin {
    "docker-plugin": ;
  }

  jenkins::plugin {
    "git": ;
  }

  jenkins::plugin {
    "mercurial": ;
  }

  jenkins::plugin {
    "xunit": ;
  }

  package {'mercurial':
    ensure => installed
  }

  package {'python-pip':
    ensure => installed
  }

  python::pip { 'fig':
    pkgname => 'fig'
  }

  package {'apt-transport-https':
    # required to use docker's apt repo
    ensure => installed,
    before => Package['lxc-docker'],
  }

  apt::source {'docker':
    location          => 'https://get.docker.io/ubuntu',
    release           => '',
    repos => 'docker main',
    key               => '36A1D7869245C8950F966E92D8576A8BA88D21E9',
    key_server        => 'keyserver.ubuntu.com',
    include_src       => false,
    before => Package['lxc-docker'],
  }

  package {'lxc-docker':
    # This is pulled from Docker's repo, so we get a version that
    # is compatible with the Jenkins docker plugin.
    ensure => installed,
  }

  file {'/etc/default/docker':
    source => "puppet:///modules/kallitheaci/default-docker",
    notify => Service["docker"],
    mode => 600,
    owner => root,
    group => root,
  }

  service {'docker':
    ensure => running,
  }

  Package['lxc-docker'] -> Service['docker']
}
