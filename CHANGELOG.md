# Changelog for Debian-Mediawiki

Need to keep track of things so that I could remember better why I changed things.

### To-Do

- Adding `Makefile` to simplify the build process, with variable management to select which version of MediaWiki at image generation time. Currently, the `ENV` variable within `Dockerfile` is buried quite deep inside.
- Run the development version 1.35 to test the Parsoid/PHP with VisualEditor.
 

### 2020-07-05: Project Started

Project ported from using Alpine as base to Debian. Words going around that Alpine is not suitable running as base image despite its size.

Also, I just learned that the development team has switched to [implementing Parsoid in PHP](https://www.mediawiki.org/wiki/Parsoid/PHP), moving away from the Javascript implementation with the long-term goal of having both Parsoid and VisualEditor built-in to the code MediaWiki codebase and also to address some concerns regarding the architectural design of Parsoid.

To generate Docker container image based on my custom `Dockerfiles/Dockerfile-*` configs, run:

```bash
$ docker build -f Dockerfiles/Dockerfile-mwiki -t debian-mediawiki .
```


### 2020-07-6: VisualEditor and Parsoid/PHP

