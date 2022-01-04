#!/bin/sh

# Exit on error
set -e

echo "Starting iTop..."

#=== Set shared folder permissions ===
folders="conf data log env-production env-production-build"

mkdir -vp $folders

{
  if [ -f "$APACHE_ENVVARS" ]; then
    . "$APACHE_ENVVARS"
    chown -R "$APACHE_RUN_USER:$APACHE_RUN_GROUP" $folders
  else
    chown -R www-data:www-data $folders
  fi
  chmod 775 $folders
}

##=== Check database vars ===
#=== DB host ===
if [ -z "$ITOP_DB_HOST" -a ! -e "./config/database.php" ]; then
  echo >&2 'WARN: missing ITOP_DB_HOST environment variable'
  echo >&2 '  Did you forget to --link some_mysql_container:db ?'
else
  #=== DB user and pass ===
  : ${ITOP_DB_USER:=root}
  if [ "$ITOP_DB_USER" = 'root' ]; then
    : ${ITOP_DB_PASS:=$DB_ENV_MYSQL_ROOT_PASSWORD}
  fi

  if [ -z "$ITOP_DB_PASS" ]; then
    echo >&2 'ERROR: missing required ITOP_DB_PASS environment variable'
    echo >&2 '  Did you forget to -e ITOP_DB_PASS=... ?'
    echo >&2
    echo >&2 '  (Also of interest might be ITOP_DB_USER and ITOP_DB_NAME.)'
    exit 1
  #=== Setup database if needed ===
  elif [ 0 -eq 1 ]; then # TODO : Add something like: php setup/maintenance.php --vars...
    {
      echo "<?php"
      echo "\$DB['server'] = '$ITOP_DB_HOST';"
      echo "\$DB['user'] = '$ITOP_DB_USER';"
      echo "\$DB['password'] = '$ITOP_DB_PASS';"
      echo "\$DB['db'] = '${ITOP_DB_NAME:-itop}';"
      echo "\$DB['prefix'] = '${ITOP_DB_PREFIX}';"
      echo "\$DB['type'] = '${ITOP_DB_TYPE:-mysqli}';"
    } | tee ./config/database.php
  fi
fi

#=== Configure php ===
{
  echo "# php settings:"
  echo "date.timezone       = $PHP_TIMEZONE"
  echo "file_upload         = $PHP_ENABLE_UPLOADS"
  echo "register_globals    = Off"
  echo "safe_mode           = Off"
  echo "memory_limit        = $PHP_MEMORY_LIMIT"
  echo "post_max_size       = $PHP_POST_MAX_SIZE"
  echo "upload_max_filesize = $PHP_UPLOAD_MAX_FILESIZE"
  echo "max_file_uploads    = $PHP_MAX_FILE_UPLOADS"
  echo "max_input_time      = $PHP_MAX_INPUT_TIME"
  echo "log_errors          = $PHP_LOG_ERRORS"
  echo "error_reporting     = $PHP_ERROR_REPORTING"
} | tee $PHP_INI_DIR/conf.d/php.ini

#=== Set recommanded opcache settings ===
# see https://secure.php.net/manual/en/opcache.installation.php
{
  echo "opcache.memory_consumption      = 128"
  echo "opcache.interned_strings_buffer = 8"
  echo "opcache.max_accelerated_files   = 4000"
  echo "opcache.revalidate_freq         = 2"
  echo "opcache.fast_shutdown           = 1"
  echo "opcache.enable_cli              = 1"
} | tee $PHP_INI_DIR/conf.d/opcache-recommended.ini

docker-php-entrypoint "$@"

