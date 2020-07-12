# Backing Up Strategy

Backing up is really important.

### Basic Workflow To Back Up

First, locate the `LocalSettings.php` and back that up first.

Second, exporting database from `postgres` container can be done with `pg_dump` tool.

```console
$ docker exec -t postgres pg_dump -U wiki wiki > dump_`date +%d-%m-%Y"_"%H_%M`.sql
```

The `-U` flag specifies the user and the `wiki` key without any prior flag is the name of the database. The database dump is timestamped with `date` command.


### Basic Workflow To Restore

[To Be Added]

### Scripted Workflow with Makefile

[To Be Added]

### Automated Scripted Workflow with Cron

[To Be Added]
