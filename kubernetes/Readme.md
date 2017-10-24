# Zammad kubernetes example deployment

## Perquisites

- On every node you need to set `sysctl -w vm.max_map_count=262144`
- Change the ingress to your needs.

## Amazon S3 Backup

If you want to be synced with a S3 bucket, then just fill the `30_secret_backup.yaml` with your secret and access keys.

```bash
echo -n "ACCESS_KEY" | base64
echo -n "SECRET_KEY" | base64
```

Change the bucket path in the `20_configmap_backup.yaml`.

That's it.

## Deploy zammad

Hit `kubectl apply -f ./` and wait till everything is setup.