# iTop on Docker

This repo provides a quick way to start a demo environnement for iTop 2.7 LTS. The Dockerfile is also suitable for production usage.

## How to Use

Clone the repo and use docker compose:

    docker-compose up

The command above starts 3 containers as following:

_Running using local volumes:_
- **mariadb**: database with xtrabackup support
- **adminer**: a PHP tool to have a look on your database.

_Running apache web server with PHP support:_
- **itop**: version 2.7 LTS

All volumes are mounted in `./volumes`.

Then services will be available at following addresses:

- iTop: (http://localhost:8080)
- adminer: (http://localhost:8000)

> Please ignore the session warning. See https://github.com/docker-library/php/issues/201

## Environment variables

### Database link

- **ITOP_DB_HOST** = db
- **ITOP_DB_NAME** = itop
- **ITOP_DB_USER** = itop
- **ITOP_DB_PASS** = itop

### Php settings

- **PHP_TIMEZONE** = "Europe/Paris"
- **PHP_ENABLE_UPLOADS** = "On"
- **PHP_MEMORY_LIMIT** = "256M"
- **PHP_POST_MAX_SIZE** = "10M"
- **PHP_UPLOAD_MAX_FILESIZE** = "8M"
- **PHP_MAX_FILE_UPLOADS** = "20"
- **PHP_MAX_INPUT_TIME** = "300"
- **PHP_LOG_ERRORS** = "On"
- **PHP_ERROR_REPORTING** = "E_ALL" _Production Value: E_ALL & ~E_DEPRECATED & ~E_STRICT_

## License

MIT

## Author

MerhylStudio <shk@merhylstudio.fr>

