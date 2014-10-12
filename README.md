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
