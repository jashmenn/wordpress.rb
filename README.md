Wordpress.rb
============
Update a wordpress blog from the command-line.

Setup
=====

  cp config/wordpressrb.yml.example ~/.wordpressrb.yml
  vi ~/.wordpressrb.yml

Usage
=====

  echo "hello world" | ruby bin/wordpress-post.rb --title testing

Help
====
bin/wordpress-post.rb --help

TODO
====
* refactor for git-style binaries
* create rubygem
* add in more actions

Authors
=======
wordpress.rb (c) 2009 Nate Murray
Based on work by John Mettraux
http://jmettraux.wordpress.com/2007/11/05/posting-to-wordpress-via-ruby-and-atompub/
