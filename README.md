# Welcome to Zammad

Zammad is a web based open source helpdesk/ticket system with many features
to manage customer communication via several channels like telephone, facebook,
twitter, chat and e-mails. It is distributed under the GNU AFFERO General Public
 License (AGPL) and tested on Linux, Solaris, AIX, FreeBSD, OpenBSD and Mac OS
10.x. Do you receive many e-mails and want to answer them with a team of agents?
You're going to love Zammad!

## What is zammad-docker-compose repo for?

This repo is meant to be the starting point for somebody who likes to use dockerized multi-container Zammad in production.

## Getting started with zammad-docker-compose

https://docs.zammad.org/en/latest/install-docker-compose.html

## Build Status

[![Build Status](https://travis-ci.org/zammad/zammad-docker-compose.svg?branch=master)](https://travis-ci.org/zammad/zammad-docker-compose)

## Using a reverse proxy

In environments with more then one web applications it is necessary to use a reverse proxy to route connections to port 80 and 443 to the right application.
To run Zammad behind a revers proxy, we provide `docker-compose.proxy-example.yml` as a starting point.

1.  Copy `./.examples/proxy/docker-compose.proxy-example.yml` to your own configuration, e.g. `./docker-compose.prod.yml`  
    `cp ./.examples/proxy/docker-compose.proxy-example.yml ./docker-compose.prod.yml`
1.  Modify the environment variable `VIRTUAL_HOST` and the name of the external network in `./docker-compose.prod.yml` to fit your environment.
1.  Run docker-composer commands with the default and your configuration, e.g. `docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d`  

See `.examples/proxy/docker-compose.yml` for an example proxy project.

Like this, you can add your `docker-compose.prod.yml` to a branch of your Git repository and stay up to date by merging changes to your branch.
