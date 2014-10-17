# Lifemessager

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
