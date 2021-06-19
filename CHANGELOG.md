# Changelog for Debian-Mediawiki

Need to keep track of things so that I could remember better why I changed things.

**Table of Contents**:

1. [To-Do](#to-do)
2. [2020-07-05: Project Started](#2020-07-05-project-started)
3. [2020-07-12: Change from Git Clone to Tarball](#2020-07-12-change-from-git-clone-to-tarball)
4. [2020-08-01: Testing 1.35 RC0](#2020-08-01-testing-1.35-rc0)
5. [2020-09-26: Testing 1.35.0 (Stable Release)](#2020-09-26-testing-1.35.0-stable-release)
6. [2020-09-26: Testing Back-Up](#2020-09-26-testing-back-up)
7. [2021-06-16: Testing v1.36.0](#2021-06-16-testing-v1.36.0)
8. [2021-06-18: Debugging VisualEditor](#2021-06-18-debugging-visualeditor)
9. [2021-06-18: Testing Backup and Restore](#2021-06-18-testing-backup-and-restore)

***

## To-Do

- [ ] Adding `Makefile` to simplify the build process, with variable management to select which version of MediaWiki at image generation time. Currently, the `ENV` variable within `Dockerfile` is buried quite deep inside.
- [ ] Add script to perform backup, and figure out way to automate it.
- [X] Test backup and restore from v1.35 to v1.36.
- [X] Run the development version 1.35 to test the Parsoid/PHP with VisualEditor.
- [X] Add v1.36

***

## 2020-07-05: Project Started

Project ported from using Alpine as base to Debian. Words going around that Alpine is not suitable running as base image despite its size.

Also, I just learned that the development team has switched to [implementing Parsoid in PHP](https://www.mediawiki.org/wiki/Parsoid/PHP), moving away from the Javascript implementation with the long-term goal of having both Parsoid and VisualEditor built-in to the code MediaWiki codebase and also to address some concerns regarding the architectural design of Parsoid.

To generate Docker container image based on my custom `Dockerfiles/Dockerfile-*` configs, run:

```bash
$ docker build -f Dockerfiles/<version> -t debian-mediawiki:<version> .
```

## 2020-07-12: Change from Git Clone to Tarball

I was not quite satisfied with the large image size of 1.52 GB. So I studied, implement some Docker best practices. I found out that with the `git` install method, it caused the image size to balloon up to 1.5 GB. So I replaced it with tarball installation method and the final image was below 700 MB. The downside is that this way I could not access the latest developmental build, which is fine for now.

In anticipation for the built-in Parsoid (ported into PHP from NodeJS, slated in 2020), I am removing `Dockerfile-parsoid`.

## 2020-08-01: Testing 1.35 RC0

Got an email recently about the availability of the release candidate version. VisualEditor is now bundled, but I could not get it to talk to the Parsoid service (something about `curl error:7`). VisualEditor is located inside the `extension` folder while Parsoid is located inside `vendor/mediawiki` folder.

## 2020-09-26: Testing 1.35.0 (Stable Release)

There is one additional step to get the VisualEditor and Parsoid running. The latest image was built with this command:

```bash
docker build -f Dockerfiles/v1_35 -t debian-mediawiki:135 .
```

Which means, the latest image is available at `mediawiki:135`. To get the Parsoid working (as of date, no official working tutorial yet), this line was added to `LocalSettings.php` at the very bottom.

```php
wfLoadExtension( 'Parsoid', 'vendor/wikimedia/parsoid/extension.json' );
$wgEnableRestAPI = true;
$wgParsoidSettings = [];
$wgVirtualRestConfig['modules']['parsoid'] = array(
	'url' => 'http://localhost/rest.php',
	'domain' => 'localhost',
);
```

Based on developers' discussion on Wikimedia Phabricator task [T248343](https://phabricator.wikimedia.org/T248343), this is still not quite final yet.


## 2020-09-26: Testing Back-Up

So, direct upgrade from v1.34 to v1.35 did not actually go well. I got some PHP-related errors after running `php update.php`. So I had to burn the whole thing down and re-install. Things got challenging when I was trying to restore the database. I got this to work with these commands, after installing the mediawiki.

```bash
# Drop wiki db, this would actually delete the db!!
docker exec -i postgres dropdb -U wiki wiki 

# Create the db
docker exec -i postgres createdb -U wiki wiki 

# Restore from pg_dump backup
docker exec -i postgres psql -d wiki -U wiki < backup/dump.sql
```

Here, `postgres` is the name of the container. Both commands `dropdb` and `createdb` come with Postgres installation. These are actually the wrappers for SQL commands.

## 2021-06-16: Testing v1.36.0

Current latest stable release.

Looks like the same hack as I did on `2020-09-26` was required to get the Parsoid and VisualEditor properly working (error with `curl`).

Somehow, this feels like a Docker-related issue.

## 2021-06-18: Debugging VisualEditor

```php
wfLoadExtension( 'Parsoid', 'vendor/wikimedia/parsoid/extension.json' );
$wgVirtualRestConfig['modules']['parsoid'] = array(
	'url' => 'http://localhost/rest.php',
);
```

This seems to be the minimal configuration needed to be able to use VisualEditor when running MediaWiki `v1.36` in a Docker container. So yeah, it does feel like a Docker-related problem now.

## 2021-06-18: Testing Backup and Restore

Dumping SQL file from the `v1.35` and restoring it to `v1.36`. This is for a planned migration from `v1.35` to `v1.36`.

First, let's *visit* the container for a quick tour.

```shell
docker exec -it mediawiki_136 /bin/bash
cd /var/www/mediawiki/maintenance
```

Scripts related to maintenance can be found inside that `maintenance` folder. The one that we are interested in is the `importDump.php` to import the XML-dump file from previous/other MediaWiki installation.

I issued the following comment inside the `maintenance` folder on the Docker container.

```shell
php importDump.php --dry-run
```

And I was greeted with the following error on the console:

```
PHP Fatal error:  Uncaught Exception: Unable to open file vendor/wikimedia/parsoid/extension.json: filemtime(): stat failed for vendor/wikimedia/parsoid/extension.json in /var/www/mediawiki/includes/registration/ExtensionRegistry.php:176
Stack trace:
#0 /var/www/mediawiki/includes/GlobalFunctions.php(52): ExtensionRegistry->queue('vendor/wikimedi...')
#1 /var/www/mediawiki/LocalSettings.php(171): wfLoadExtension('Parsoid', 'vendor/wikimedi...')
#2 /var/www/mediawiki/includes/Setup.php(145): require_once('/var/www/mediaw...')
#3 /var/www/mediawiki/maintenance/doMaintenance.php(90): require_once('/var/www/mediaw...')
#4 /var/www/mediawiki/maintenance/importDump.php(358): require_once('/var/www/mediaw...')
#5 {main}
  thrown in /var/www/mediawiki/includes/registration/ExtensionRegistry.php on line 176
```

After disabling the `parsoid` extension through the `LocalSettings.php`, the `importDump.php` script was working again. Now, let's try import from outside of the container, with the XML dump file present in the same folder.

**!! WARNING !!** Similarly, backing up when `parsoid` is running will not work. Well, this is annoying.

```bash
# First, try dry-run
docker exec -i mediawiki_136 php /var/www/mediawiki/maintenance/importDump.php --dry-run
```

Curiously, it took time... that I had to `Ctrl` + `c` to stop it. To be on the safe side, I am going to upload the XML dump file by using `docker cp` command.

```bash
# Copy, from host to container
docker cp dump.xml mediawiki_136:/dump.xml

# Inside the run after docker exec -it, test the backup
php /var/www/mediawiki/maintenance/importDump.php --dry-run

# If the dry-run command above worked, test it with the uploaded xml
php /var/www/mediawiki/maintenance/importDump.php < dump.xml
```

Received error when importing, did not seem that the import happened. Went back to the `mediawiki` container (running `v1.35`) and ran `rebuildrecentchanges.php` and `initSiteStats.php` inside the `maintenance` folder (both were run with `parsoid` turned off).


**!! NOTE !!** Even with steps above taken before dumping XML, the import did not work.

**!! NOTE !!** Well, looks like we will have to do the backup strategy with SQL.

Performed SQL operation to restore `dump.sql` with strategy devised on `2021-06-16`. Greeted with an error on the browser after completion: `Fatal exception of type "Wikimedia\Rdbms\DBQueryError"`

The advise is to run `update.php` (with `parsoid` turned off).

```bash
docker exec -i mediawiki_136 php /var/www/maintenance/update.php
```

Lmao, I got this error message now: `Can not upgrade from versions older than 1.27, please upgrade to that version or later first`.

Well, this is frustrating.

**!! NOTE !!** Okay found the problem: by default, `v1.36` installation uses `mediawiki` as the schema, while I had `wiki` for my `v1.35` installation. By re-installing `v1.36` with `wiki` as the schema, the `update.php` script ran just fine after importing the SQL.

Testing ended successfully.
