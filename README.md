Defollow Notify ( Twitter )
===========================

Defollow Notify is a free and Open Source script that allows you to notify (and to be notified) , with a tweet, the  defollow of users.

Requirements
------------

* GNU/Linux ( Debian, Ubuntu, Gentoo, Archlinux, etc..) OR Mac OS X
* Bash Shell
* Curl

Install
-------

`$ chmod +x install.sh`

`$ sudo ./install.sh`

On OS X you must install `md5sha1sum` using using [Homebrew](http://brew.sh) and create `/usr/local/src/` directory manually.

Run
---

`$ defollownotify`

The firt time `defollownotify` download the list of users from Twitter and will create the `ids.xml`. Launching for the second time to control the defollow.

Uninstall
---------

`$ chmod +x uninstall.sh`

`$ sudo ./uninstall.sh`




