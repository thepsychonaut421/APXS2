# apxs2-vhost #

Apache HTTPD Server VirtualHost Template

### Getting Started ###

1. Before running the `setup.sh` script, make sure you have copied over your SSL cerificate files to the `./private/ssl` directory. The required file names can be found in `./private/ssl/index.txt`. Alternately you can remove the `<VirtualHost *:443>` directive from the `httpd.template.conf` file. 

2. To complete setup without user input, change the values in `./private/etc/setup.cnf` to values specific to your setup before running running the `setup.sh` script.

3. Run the setup script: `./private/bin/setup.sh`.
