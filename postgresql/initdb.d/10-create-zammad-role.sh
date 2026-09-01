#!/bin/bash
#
# Provision the database that Zammad uses, owned by a dedicated login role.
#
# The postgres image unconditionally makes its bootstrap role ($POSTGRES_USER) a
# superuser. Zammad does not need any superuser capability - it only owns its own
# database and relies on the built-in plpgsql extension - so the application role is
# created here as a plain login role instead of being reused from the bootstrap role.
#
# This runs only while an empty data directory is being initialised. Installations
# whose volume already exists keep the role layout they were created with; see the
# README for how to migrate those.

# Note that the postgres entrypoint sources this file when it is not executable, so
#   avoid shell options that would leak into it and break the rest of the startup.
set -o errexit
set -o pipefail

: "${ZAMMAD_DB:?is not set, it must be provided by the compose file}"
: "${ZAMMAD_DB_USER:?is not set, it must be provided by the compose file}"
: "${ZAMMAD_DB_PASS:?is not set, it must be provided by the compose file}"

echo "Creating the '${ZAMMAD_DB_USER}' role and the '${ZAMMAD_DB}' database…"

# Identifiers and the password are passed as psql variables and quoted by format()
#   with %I / %L, so that no shell quoting can leak into the generated statements.
psql --variable ON_ERROR_STOP=1 \
     --username "${POSTGRES_USER}" \
     --dbname "${POSTGRES_DB}" \
     --variable role="${ZAMMAD_DB_USER}" \
     --variable pass="${ZAMMAD_DB_PASS}" \
     --variable db="${ZAMMAD_DB}" <<-'EOSQL'
	SELECT format('CREATE ROLE %I LOGIN PASSWORD %L', :'role', :'pass')
	WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = :'role')\gexec

	SELECT format('CREATE DATABASE %I OWNER %I', :'db', :'role')
	WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = :'db')\gexec

	GRANT ALL PRIVILEGES ON DATABASE :"db" TO :"role";
EOSQL
