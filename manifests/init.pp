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
    pkgname => 'fig',
    url => 'git+https://github.com/docker/fig.git#egg=fig'
  }

  python::pip { 'jenkins-job-builder':
    pkgname => 'jenkins-job-builder',
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

  file {'/var/lib/jenkins/config.xml':
    content => template('kallitheaci/jenkins/config.xml.erb'),
    mode => 644,
    owner => jenkins,
    group => jenkins
  }

  file {'/var/lib/jenkins/users':
    mode => 755,
    ensure => directory,
    owner => jenkins,
    group => jenkins
  }

  file {'/var/lib/jenkins/users/kallithea':
    mode => 755,
    ensure => directory,
    owner => jenkins,
    group => jenkins
  }

  file{'jenkins-user-kallithea-config.xml':
    path => '/var/lib/jenkins/users/kallithea/config.xml',
    content => template('kallitheaci/jenkins/user-kallithea-config.xml.erb'),
    mode => 644,
    owner => jenkins,
    group => jenkins
  }

  file{'/etc/jenkins_jobs':
    mode => 700,
    ensure => directory,
    owner => jenkins,
    group => jenkins,
  }

  file{'jenkins_jobs.ini':
    path => '/etc/jenkins_jobs/jenkins_jobs.ini',
    content => template('kallitheaci/jenkins/jobs/jenkins_jobs.ini.erb'),
    mode => 600,
    owner => jenkins,
    group => jenkins,
  }

  file{'kallithea.yml':
    path => '/etc/jenkins_jobs/kallithea.yml',
    content => template('kallitheaci/jenkins/jobs/kallithea.yml.erb'),
    mode => 600,
    owner => jenkins,
    group => jenkins,
  }

  File['/var/lib/jenkins/users'] -> File['/var/lib/jenkins/users/kallithea']
  File['/var/lib/jenkins/users/kallithea'] -> File['jenkins-user-kallithea-config.xml']
  File['/etc/jenkins_jobs'] -> File['jenkins_jobs.ini']
  File['/etc/jenkins_jobs'] -> File['kallithea.yml']
  Package['lxc-docker'] -> Service['docker']
}
