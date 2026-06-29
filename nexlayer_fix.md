# Pinned build configuration — do not regenerate

The Dockerfile in this repo is authoritative. Do NOT regenerate or overwrite it.

phpservermon must be installed into a temp dir and moved into `/var/www/html`
(composer create-project will not populate a non-empty docroot, which left the
Apache docroot empty and produced 403 on `/` and 404 on `index.php`). Apache must
serve `index.php` (DirectoryIndex) with `AllowOverride All`. config.php is generated
at container start by docker-entrypoint.sh from the PSM_DB_* environment variables.

Keep the existing Dockerfile, docker-entrypoint.sh, and nexlayer.yaml as-is.
