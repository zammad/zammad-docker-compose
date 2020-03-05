# Welcome to Zammad

Zammad is a web based open source helpdesk/ticket system with many features
to manage customer communication via several channels like telephone, facebook,
twitter, chat and e-mails. It is distributed under the GNU AFFERO General Public
 License (AGPL). Do you receive many e-mails and want to answer them with a team of agents?
You're going to love Zammad!


## What is zammad-docker-compose repo for?

This repo is meant to be the starting point for somebody who likes to use dockerized multi-container Zammad in production.


## Getting started with zammad-docker-compose

https://docs.zammad.org/en/latest/install-docker-compose.html


## CI Status

[![CI Status](https://github.com/zammad/zammad-docker-compose/workflows/ci/badge.svg)](https://github.com/zammad/zammad-docker-compose/actions)

## Using a reverse proxy

In environments with more then one web applications it is necessary to use a reverse proxy to route connections to port 80 and 443 to the right application.
To run Zammad behind a revers proxy, we provide `docker-compose.proxy-example.yml` as a starting point.

1.  Copy `./.examples/proxy/docker-compose.proxy-example.yml` to your own configuration, e.g. `./docker-compose.prod.yml`  
    `cp ./.examples/proxy/docker-compose.proxy-example.yml ./docker-compose.prod.yml`
1.  Modify the environment variable `VIRTUAL_HOST` and the name of the external network in `./docker-compose.prod.yml` to fit your environment.
1.  Run docker-composer commands with the default and your configuration, e.g. `docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d`  

See `.examples/proxy/docker-compose.yml` for an example proxy project.

Like this, you can add your `docker-compose.prod.yml` to a branch of your Git repository and stay up to date by merging changes to your branch.


## Using Rancher

* RANCHER_URL=http://RANCHER_HOST:8080 rancher-compose --env-file=.env up

## Upgrading

### From =< 3.3.0-12

We've updated the Elasticsearch image from 5.6 to 7.6. 
As there is no direct upgrade path we have to delete all Elasticsearch indicies and rebuild them.
Do the following to empty the ES docker volume:

```
docker-compose stop
rm -r $(docker volume inspect zammaddockercompose_elasticsearch-data | grep Mountpoint | sed -e 's#.*": "##g' -e 's#",##')/*
docker-compose start
```

To workaround the [changes in the PostgreSQL 9.6 container](https://github.com/docker-library/postgres/commit/f1bc8782e7e57cc403d0b32c0e24599535859f76) do the following:

```
docker-compose start
docker exec -it zammaddockercompose_zammad-postgresql_1 bash
psql --username postgres --dbname zammad_production
CREATE USER zammad;
ALTER USER zammad WITH PASSWORD 'zammad';
ALTER USER zammad WITH SUPERUSER CREATEDB;
```
