# Backing Up Strategy

Backing up is really important.

### Basic Workflow To Back Up

First, locate the `LocalSettings.php` and back that up first.

Second, exporting database from `postgres` container can be done with `pg_dump` tool.

```console
$ docker exec -t postgres pg_dump -U wiki wiki > dump_`date +%Y-%m-%d"_"%H_%M`.sql
```

The command above would produce an `*.sql` file like this: `dump_2020-08-02_10_10.sql`.

The `-U` flag specifies the user and the `wiki` key without any prior flag is the name of the database. The database dump is timestamped with `date` command.


### Basic Workflow To Restore

To avoid potential problems stemming for version incompatibility, make sure that the target and the origin MediaWiki installation are from the same version (e.g. from v1.34 to v1.34, not from v1.33 to v1.35).

### Scripted Workflow with Makefile

[To Be Added]

### Automated Scripted Workflow with Cron

[To Be Added]
