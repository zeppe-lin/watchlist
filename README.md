OVERVIEW
========

This repository contains RSS/Atom feeds for the software used in
Zeppe-Lin pkgsrc collections.

The purpose of these feeds is to help maintainers watch for upstream
software updates.


USAGE
=====

Import `snownews.opml` into any feed reader you like.
For **snownews**, copy this file to `~/.config/snownews/urls.opml`.

For **newsraft**, use `newsraft` file:

```sh
newsraft -f /path/to/newsraft
```


MAINTAINING
===========

Run `make` to see available targets.

- `check-dups` - check for duplicated URLs
- `check-missing` - check for missing feeds
- `check-redundant` - check for redundant feeds
- `gen-newsraft` - generate Newsraft feeds file
- `gen-snownews` - generate Snownews OPML file
- `sort-pkgsrcs` - sort collection packages by name

Collections are defined in `pkgsrc-*.txt` files.


LICENSE
=======

`watchlist` is licensed under WTFPLv2 License.

See `LICENSE` file for copyright and license details.
