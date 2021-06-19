# Backing Up Strategy

Backing up is really important.

1. [Notes](#notes)
2. [Backing Up](#backing-up)
3. [Restoring](#restoring)

***

## Notes

1. Ensure that the DB schema prefix is the same between the backup and the target to restore.
2. For some reason, the PHP maintenance scripts would not work if `parsoid` is defined inside the `LocalSettings.php`. Comment the `parsoid` code block first before running any of the maintenance scripts.

## Backing Up

First, locate the `LocalSettings.php` and back that up first.

Second, exporting database from `postgres` container can be done with `pg_dump` tool.

```console
$ docker exec -t postgres pg_dump -U wiki wiki > dump_`date +%Y-%m-%d"_"%H_%M`.sql
```

The command above would produce an `*.sql` file like this: `dump_2020-08-02_10_10.sql`.

The `-U` flag specifies the user and the `wiki` key without any prior flag is the name of the database. The database dump is timestamped with `date` command.

## Restoring

When migrating from the same (major) version of MediaWiki (i.e. `v1.35.0` to `v1.35.2`), typically it should work without much problem. When migrating between major versions (i.e. `v1.35.0` to `v1.36.0`), please anticipate some issues. However, they could be easily resolved by running the `maintenance/update.php` script.

On the new set of instance, run the following commands:

```bash
docker exec -i $POSTRGRES dropdb -U wiki wiki
docker exec -i $POSTRGRES createdb -U wiki wiki
docker exec -i $POSTRGRES psql -d wiki -U wiki < backup/<sql dump file>
docker exec -i $MEDIAWIKI php /var/www/mediawiki/maintenance/update.php
```

Where the `$POSTGRES` and `$MEDIAWIKI` are the PostgreSQL and Mediawiki container, respectively.
