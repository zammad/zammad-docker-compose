# Welcome to Zammad

Zammad is a web based open source helpdesk/ticket system with many features
to manage customer communication via several channels like telephone, facebook,
twitter, chat and emails. It is distributed under the GNU AFFERO General Public
 License (AGPL). Do you receive many emails and want to answer them with a team of agents?
You're going to love Zammad!

## Use case for this repository

This repository is meant to be the starting point for somebody who likes to use dockerized multi-container Zammad in production.

## Getting started with zammad-docker-compose

[Learn more on Zammads documentation](https://docs.zammad.org/en/latest/install/docker-compose.html)

## Status

[![CI Status](https://github.com/zammad/zammad-docker-compose/workflows/ci/badge.svg)](https://github.com/zammad/zammad-docker-compose/actions) [![Docker Pulls](https://badgen.net/docker/pulls/zammad/zammad-docker-compose?icon=docker&label=pulls)](https://hub.docker.com/r/zammad/zammad-docker-compose/)

## Using a reverse proxy

In environments with more then one web applications it is necessary to use a reverse proxy to route connections to port 80 and 443 to the right application.
To run Zammad behind a reverse proxy, we provide `docker-compose.proxy-example.yml` as a starting point.

1. Copy `./.examples/proxy/docker-compose.proxy-example.yml` to your own configuration, e.g. `./docker-compose.prod.yml`
    `cp ./.examples/proxy/docker-compose.proxy-example.yml ./docker-compose.prod.yml`
2. Modify the environment variable `VIRTUAL_HOST` and the name of the external network in `./docker-compose.prod.yml` to fit your environment.
3. Run docker-composer commands with the default and your configuration, e.g. `docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d`

See `.examples/proxy/docker-compose.yml` for an example proxy project.

Like this, you can add your `docker-compose.prod.yml` to a branch of your Git repository and stay up to date by merging changes to your branch.

## Using Rancher

```console
RANCHER_URL=http://RANCHER_HOST:8080 rancher-compose --env-file=.env up
```

## Running without Elasticsearch

Elasticsearch is an optional, but strongly recommended dependency for Zammad. More details can be found in the [documentation](https://docs.zammad.org/en/latest/prerequisites/software.html#elasticsearch-optional). There are however certain scenarios when running without Elasticsearch may be desired, e.g. for very small teams, for teams with limited budget or as a temporary solution for an unplanned Elasticsearch downtime or planned cluster upgrade.

Elasticsearch is enabled by default in the example `docker-compose.yml` file. It is also by default required to run the "zammad-init" command. Disabling Elasticsearch is possible by setting a special environment variable: `ELASTICSEARCH_ENABLED=false` for the `zammad-init` container and removing all references to Elasticsearch everywhere else: the `zammad-elasticsearch` container, it's volume and links to it.

## Upgrading

### From =< 3.3.0-12

We've updated the Elasticsearch image from 5.6 to 7.6.
As there is no direct upgrade path we have to delete all Elasticsearch indices and rebuild them.
This will depend on the name of your docker container and volume, which depends on the checkout directory (`zammad-docker-compose` by default):

```console
docker-compose stop
docker container rm zammad-docker-compose_zammad-elasticsearch_1
docker volume rm zammad-docker-compose_elasticsearch-data
docker-compose up --no-recreate
```

To workaround the [changes in the PostgreSQL 9.6 container](https://github.com/docker-library/postgres/commit/f1bc8782e7e57cc403d0b32c0e24599535859f76) do the following:

```console
docker-compose start
docker exec -it zammaddockercompose_zammad-postgresql_1 bash
psql --username postgres --dbname zammad_production
CREATE USER zammad;
ALTER USER zammad WITH PASSWORD 'zammad';
ALTER USER zammad WITH SUPERUSER CREATEDB;
```

### From =< 3.6.0-65

To be able to run Zammad container with an unprivileged user we had to change the port Nginx uses from 80 to 8080, so Zammad needs to be accessed via <http://localhost:8080> instead of <http://localhost> now!

This change will also affect you, if you use a reverse proxy, like Traefik or Haproxy, in front of Zammad as your reverse proxy configuration needs to be adapted to point to port 8080 now.

### From =< 4.0.0 to 5.0.0

Memchached config changed. If you use the old env vars `MEMCACHED_HOST` & `MEMCACHED_PORT` adapt to `MEMCACHE_SERVERS`.
Redis is a dependency for the Websocket server now.
