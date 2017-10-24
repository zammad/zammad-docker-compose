# Zammad kubernetes example deployment

## Perquisites

- On every node you need to set `sysctl -w vm.max_map_count=262144`
- Change the ingress to your needs.
- Hit `kubectl apply -f ./` and wait till everything is setup.