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

## Getting Started - Documentation

[Learn more on Zammad’s documentation](https://docs.zammad.org/en/latest/install/docker-compose.html)

## Upgrading

For upgrading instructions, see our [Releases](https://github.com/zammad/zammad-docker-compose/releases).

## PostgreSQL privileges

Zammad connects to PostgreSQL with the `zammad` role, which is a plain login role: it owns the `zammad_production` database and nothing else, and holds none of `SUPERUSER`, `CREATEDB`, `CREATEROLE`, `REPLICATION` or `BYPASSRLS`. This matches the role that the packaged Linux installation creates. Administrative access to the server is available through the separate `postgres` superuser, configurable via `POSTGRES_SUPERUSER` and `POSTGRES_SUPERUSER_PASS`.

The role is created while the `postgresql-data` volume is initialised, so this applies to new installations only. Installations created before this change connect with the bootstrap role of the `postgres` image, which is a superuser. That is not a vulnerability - reaching those privileges requires valid database credentials and network access to the database in the first place - so migrating is optional. PostgreSQL does not allow the bootstrap role to be demoted, so the migration goes through a backup and restore into a fresh volume:

```sh
# 1. Create a backup of the running installation.
docker compose run --rm --env BACKUP_ONCE=true zammad-backup

# 2. Stage that backup for the restore.
docker compose run --rm zammad-backup sh -c "mkdir /var/tmp/zammad/restore && cp /var/tmp/zammad/*gz /var/tmp/zammad/restore/"

# 3. Stop the stack. Do not pass --volumes here, it would delete the backup as well.
docker compose down

# 4. Discard the database volume, so that it gets initialised with the new role layout.
#    It is named after your compose project, by default the name of this directory.
docker volume ls --filter name=postgresql-data
docker volume rm <volume from the list above>

# 5. Start the stack again. The staged backup is restored into the new database
#    before Zammad starts up.
docker compose up --detach
```

## Running without Elasticsearch

Elasticsearch is an optional, but strongly recommended dependency for Zammad. More details can be found in the [documentation](https://docs.zammad.org/en/latest/prerequisites/software.html#elasticsearch-optional). There are however certain scenarios when running without Elasticsearch may be desired, e.g. for very small teams, for teams with limited budget or as a temporary solution for an unplanned Elasticsearch downtime or planned cluster upgrade.

Elasticsearch is enabled by default in the example `docker-compose.yml` file. It is also by default required to run the "zammad-init" command. Disabling Elasticsearch is possible by setting a special environment variable: `ELASTICSEARCH_ENABLED=false` and loading
the scenario [disable-elasticsearch-service.yml](scenarios/disable-elasticsearch-service.yml).
