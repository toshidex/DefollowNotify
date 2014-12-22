Defollow Notify ( Twitter )
===========================

Defollow Notify is a free and Open Source script that allows you to notify (and to be notified) when users defollow you with a tweet.

Requirements
------------

* GNU/Linux ( Debian, Ubuntu, Gentoo, Archlinux, etc..), Mac OS X, or BSD
* Bash Shell
* Curl

Install
-------

`$ chmod +x install.sh`

`$ sudo ./install.sh`

Run
---

`$ defollownotify`

The first time `defollownotify` is run, it downloads the list of users following you from Twitter and creates `ids.xml` to track changes.
Afterwards, running `defollownotify` tracks defollows.

Uninstall
---------

`$ chmod +x uninstall.sh`

`$ sudo ./uninstall.sh`

