# Welcome to Zammad

Are you juggling countless customer inquiries across multiple channels?
Struggling to keep your support team on the same page?
Or spending more time managing your helpdesk than delivering exceptional support to your customers?

Zammad is your Swiss Army knife - a web-based, open-source helpdesk and customer support platform
packed with features to streamline customer communication across channels like email, chat, telephone and social media.

## The Software

The Zammad software is and will stay open source. It is licensed under the GNU AGPLv3.
The source code is [available on GitHub](https://github.com/zammad/zammad) and owned by
the [Zammad Foundation](https://zammad-foundation.org/), which is independent of commercial
providers such as Zammad GmbH.

## The Company - Zammad GmbH

The development of Zammad is carried out by the [amazing team of people](https://zammad.com/en/company)
at [Zammad GmbH](https://zammad.com/) in collaboration with the community.
We love to create open source software for you. If you want to ensure the Zammad software
has a bright and sustainable future, consider becoming a Zammad customer!

> Are you tired of complex setup, configuration, backup and update tasks? Let us handle this stuff for you! 🚀
>
> The easiest and often most cost-effective way to operate Zammad is [our cloud service](https://zammad.com/en/pricing).
> Give it a try with a [free trial instance](https://zammad.com/en/getting-started)!

## Getting started

[Learn more on Zammad’s documentation](https://docs.zammad.org/en/latest/install/docker-compose.html)

## Upgrading

For upgrading instructions see our [Releases](https://github.com/zammad/zammad-docker-compose/releases).

## Status

[![ci-remote-image](https://github.com/zammad/zammad-docker-compose/actions/workflows/ci-remote-image.yaml/badge.svg)](https://github.com/zammad/zammad-docker-compose/actions/workflows/ci-remote-image.yaml) [![Dockerhub Pulls](https://badgen.net/docker/pulls/zammad/zammad-docker-compose?icon=docker&label=pulls)](https://hub.docker.com/r/zammad/zammad-docker-compose/)

## Using a reverse proxy

In environments with more then one web applications it is necessary to use a reverse proxy to route connections to port 80 and 443 to the right application.
To run Zammad behind a reverse proxy, we provide `docker-compose.proxy-example.yml` as a starting point.

1. Copy `./.examples/proxy/docker-compose.proxy-example.yml` to your own configuration, e.g. `./docker-compose.prod.yml`
    `cp ./.examples/proxy/docker-compose.proxy-example.yml ./docker-compose.prod.yml`
2. Modify the environment variable `VIRTUAL_HOST` and the name of the external network in `./docker-compose.prod.yml` to fit your environment.
3. Run docker-composer commands with the default and your configuration, e.g. `docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d`

See `.examples/proxy/docker-compose.yml` for an example proxy project.

Like this, you can add your `docker-compose.prod.yml` to a branch of your Git repository and stay up to date by merging changes to your branch.

## Using Rancher

```console
RANCHER_URL=http://RANCHER_HOST:8080 rancher-compose --env-file=.env up
```

## Running without Elasticsearch

Elasticsearch is an optional, but strongly recommended dependency for Zammad. More details can be found in the [documentation](https://docs.zammad.org/en/latest/prerequisites/software.html#elasticsearch-optional). There are however certain scenarios when running without Elasticsearch may be desired, e.g. for very small teams, for teams with limited budget or as a temporary solution for an unplanned Elasticsearch downtime or planned cluster upgrade.

Elasticsearch is enabled by default in the example `docker-compose.yml` file. It is also by default required to run the "zammad-init" command. Disabling Elasticsearch is possible by setting a special environment variable: `ELASTICSEARCH_ENABLED=false` for the `zammad-init` container and removing all references to Elasticsearch everywhere else: the `zammad-elasticsearch` container, its volume and links to it.
