# Lifemessager

* [HTTP API](http://docs.lifemessager.apiary.io/)

## Required

* https://github.com/sstephenson/ruby-build/wiki#suggested-build-environment
* git
* nginx
* postgresql

### ubuntu

* apt-get install libpq-dev libmagic-dev

### gentoo

* emerge -av libmagic

## configuration

```bash
cd config
cp lifemessager.yml{.example,}
vim lifemessager.yml
```

## visudo

```visudo
Cmnd_Alias LIFEMESSAGER_CMD = bin/mkdir, \
                              \
                              /bin/mv /tmp/{server_name}.crt /etc/ssl/certs, \
                              /bin/mv /tmp/{server_name}.key /etc/ssl/private, \
                              /bin/chown root\:root /etc/ssl/certs/{server_name}.crt, \
                              /bin/chown root\:root /etc/ssl/private/{server_name}.key, \
                              \
                              /bin/mv /tmp/lifemessager_{stage} /etc/nginx/sites-available, \
                              /bin/ln -fs /etc/nginx/sites-available/lifemessager_{stage} /etc/nginx/sites-enabled/lifemessager_{stage}, \
                              /etc/init.d/nginx reload \
                              \
                              /bin/ln -fs /home/lifemessager/lifemessager/shared/config/monit.conf /etc/monit.d/lifemessager, \
                              /usr/bin/monit reload, \
                              \
                              /bin/mv /tmp/unicorn_lifemessager_{stage} /etc/init.d, \
                              /usr/sbin/update-rc.d -f unicorn_lifemessager_production defaults, \
                              /bin/chown lifemessager\:lifemessager /home/lifemessager/lifemessager

lifemessager ALL=NOPASSWD: LIFEMESSAGER_CMD, \
                 (postgres) NOPASSWD: /usr/bin/psql
                 ```

## Deploy

```bash
cap production setup
cap production deploy
```

Can use `CAP_LOG_LEVEL` to set output log level. Avaliable level: `trace`, `debug`, `info`, `warn`, `error`, `fatal`.

## Troubleshooting

### crontab error

Error:

```
cannot chdir(/var/spool/cron), bailing out.
/var/spool/cron: Permission denied
```

Execute commands:

```bash
sudo groupmems -a user -g cron
sudo groupmems -a user -g crontab
```

### Guard didn't run spec after file changed

I didn't know what happend, but you can start `guard` with argument [`-p`](https://github.com/guard/guard#-p--force-polling-option)

```bash
bin/bundle exec guard -p
```
