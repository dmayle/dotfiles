# Configuration Repo

## Method Update
This repo is in the middle of migration for a pure dotfiles repo to a Nix Home
Manager configuration.

The end result will be the same, but pieces will be moving from one style to
the other.

This process is almost complete

## Installation:

```
git clone git@github.com:dmayle/dotfiles.git ~/src/dotfiles
```

Create symlinks:

```
ln -s .dotfiles/crontab ~/.crontab
```

Tell crontab to import our self-updating, version-controlled crontab

```
crontab ~/.crontab
```
