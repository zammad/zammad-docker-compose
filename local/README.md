# Instance-specific files

Everything in this folder except this README is ignored by git. Keep the files that
belong to this particular instance here - configuration snippets you mount into the
stack, your own scenario files, scripts, notes, certificates - so that they stay with
the instance and `git pull` neither reports nor touches them.

Nothing here is loaded automatically. Wire the files into the stack yourself, via
`docker-compose.override.yml` or `COMPOSE_FILE` in `.env`. Relative paths in those
resolve against the folder of `docker-compose.yml`, so refer to files here as
`./local/...`.
