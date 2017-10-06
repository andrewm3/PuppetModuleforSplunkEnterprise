# Puppet Module for Splunk Enterprise Deployments

## Splunk Multiple Deployment Options

- Splunk Search Head
- Splunk Indexers
- Splunk Cluster Master
- Splunk Deployment Server
- Splunk Heavy Forwarders
- Splunk Universal Forwarder

## Setup Requirements

[**Splunk Enterprise 6.0+**](https://www.spunk.com)
[**Splunk Universal Forwarder**](https://www.spunk.com)
[**Puppet Enterprise 2017.1.1+**](https://www.puppet.com)

## Deployment Prerequisites

Due to export compliance rules we can not offer Splunk Binary via any upstream providers or repos without any validation.
Please goto www.splunk.com, sign in with your account and download the Splunk Binary for your preferred environment
and create a simple web server (Apache, Nginx or Lighttpd) that will host the binary and allow directory listing for Apt-Get, Yum or
Windows to detect the desired packages.

In your site.pp you will need to specify the repo so puppet can utilize the package manager to install Splunk or Universal Forwarder.

CentOS or RedHat Example:

```
yumrepo { "splunk":
  baseurl => "http://privaterepo.local/",
  descr => "Splunk Private Repo",
  enabled => 1,
  gpgcheck => 0
}
```

Ubuntu Example:

```
file { "/etc/apt/apt.conf.d/99allowunsigned":
  ensure => present,
  content => "APT::Get::AllowUnauthenticated "true";\n",
}
file { "/etc/apt/sources.list.d/splunk.list":
  ensure => present,
  content => "deb http://privaterepo.local/ ./\n",
}
```

## Getting Started with Puppet Module

Example 1 - Installation of a Single Splunk Instance

```puppet
node 'singleinstance.splunkcloud.com' {
  class { 'splunk':
    httpport           => 8000,
    kvstoreport        => 8191,
    inputport          => 9997,
    reuse_puppet_certs => false,
    sslcertpath        => 'server.pem',
    sslrootcapath      => 'cacert.pem',
  }
}
```

Example 2 - Installation of a Single Splunk Instance with Universal Forwarder


```puppet
node 'singleinstance.splunkcloud.com' {
  class { 'splunk':
    httpport     => 8000,
    kvstoreport  => 8191,
    inputport    => 9997,
  }
}

node 'monitoring.splunkcloud.com' {
  class { 'splunk':
    type => 'uf',
    ds   => 'singleinstance.splunkcloud.com:8089',
  }
}
```

Example 3 - Installation of a Deployment Server, Single Search Head and Index Cluster

Hash Generator: http://passwordsgenerator.net/md5-hash-generator/

```puppet
node 'deployment.splunkcloud.com' {
  class { 'splunk':
    admin        => {
      # Set the admin password to thisisarealpassword
      hash       => '60EDE4BF095C46C43CDE66FBD090B345',
      fn         => 'Deployment Server Administrator',
      email      => 'admin@splunkcloud.com',
    },
    # Enable the web server
    httpport     => 8000,
    # Use the best-practice to forward all local events to the indexers
    tcpout       => [
      'idx1.splunkcloud.com:9997',
      'idx2.splunkcloud.com:9997',
    ],
    service      => {
      ensure     => running,
      enable     => true,
    },
  }
}

node 'sh01.splunkcloud.com' {
  class { 'splunk':
    admin        => {
      # A plaintext password needed to be able to add search peers,
      # so also make sure the indexer you're pointing to is running,
      # you can remove this if everything is up and running:
      pass       => 'thisisarealpassword',
      hash       => '60EDE4BF095C46C43CDE66FBD090B345',
      fn         => 'Search head Administrator',
      email      => 'admin@splunkcloud.com',
    },
    httpport     => 8000,
    kvstoreport  => 8191,
    # Use a License Master and Deployment Server
    lm           => 'deployment.splunkcloud.com:8089',
    ds           => 'deployment.splunkcloud.com:8089',
    tcpout       => [
      'idx1.splunkcloud.com:9997',
      'idx2.splunkcloud.com:9997', ],
    # Use these search peers
    searchpeers  => [
      'idx1.splunkcloud.com:8089',
      'idx2.splunkcloud.com:8089', ],
    # splunk must be running to be able add search peers,
    # you can remove this if everything is up and running:
    service      => {
      ensure     => running,
      enable     => true,
    },
  }
}

node 'idx1.splunkcloud.com', 'idx2.splunkcloud.com' {
  class { 'splunk':
    admin        => {
      hash       => '60EDE4BF095C46C43CDE66FBD090B345',
      fn         => 'Indexer Administrator',
      email      => 'admin@splunkcloud.com',
    },
    inputport    => 9997,
    lm           => 'deployment.splunkcloud.com:8089',
    ds           => 'deployment.splunkcloud.com:8089',
    # splunk must be running for it to be added as search peer,
    # you can remove this if everything is up and running
    service      => {
      ensure     => running,
      enable     => true,
    }
  }
}
```

Support
-------

Are you a Splunk + Puppet customer who enjoys sharing knowledge and want to put some great feature into an opensource project. We encourage you to submit issues and pull request so that we can make this Puppet Module better and help the community as a whole.

Feel free to leave comments or questions. We are here to make this community project more adaptive to all types of use cases.
