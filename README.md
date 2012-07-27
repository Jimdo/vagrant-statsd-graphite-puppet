== statsd + graphite to go ==

provision a virtual machine with vagrant and puppet to play around with statsd and graphite

goodies:

 * debian package for statsd (github.com/etsy) included 
 * port forwardings enabled
  * graphite: http://localhost:8080/
  * statsd: 8125:udp

## Installation

```
git clone https://github.com/Jimdo/vagrant-statsd-graphite-puppet.git
cd vagrant-statsd-graphite-puppet
vagrant up
```
then http://localhost:8080/


TODO:

 * put basebox somewhere public

## Contributors 

Created by jimdo https://github.com/Jimdo

Contributors

* liuggio https://github.com/liuggio