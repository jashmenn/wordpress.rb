#!/usr/bin/env ruby

# Copyright (c) 2007 John Mettraux
# Released under the MIT license
# http://www.opensource.org/licenses/mit-license.php
# http://jmettraux.wordpress.com/2007/11/05/posting-to-wordpress-via-ruby-and-atompub/

# require 'optparse'
require 'net/http'

require 'rubygems'
require 'atom/entry' # sudo gem install atom-tools
require 'atom/collection'
require 'trollop'
require 'yaml'

# some info about you and your blog

blog = "yourblog"
authorname = "Your Name"
username = ""
password = ""

bloguri = "http://localhost/wordpress/wp-admin/"
base = "http://localhost/wordpress/wp-app.php"

#
# parse options

tags = []
title = nil
type = 'html'


opts = Trollop::options do
  version "wordpres 0.0.1 (c) 2009 Nate Murray"
  banner <<-EOS
wordpres - edit a wordpress blog the cli

Usage: post.rb [options] content
where [options] are:
EOS
  opt :category, "tag/category. specify multiple times for multiple categories", :type => String, :multi => true
  opt :title, "title for the post", :required => true
  opt :type, "type of the content [html|xhtml|text]", :default => 'html', :type => String
  opt :config, "path to config file containing blog specifications", :default => File.expand_path('~/.wordpressrb.yml'), :type => String
  opt :blog, "short name of the blog to use", :default => 'default'
end
Trollop::die :type, "type must be one of [html|xhtml|text]" unless opts[:type] =~ /^(x?html|text)$/i

content = ""
loop do
    line = STDIN.gets
    break unless line
    content += line
end

#
# create entry

entry = Atom::Entry.new
entry.title = title
#entry.updated = Time.now.httpdate
entry.updated!

author = Atom::Author.new
author.name = authorname
author.uri = bloguri
entry.authors << author

tags.each do |t|
    c = Atom::Category.new
    c["scheme"] = bloguri
    c["term"] = t.strip
    entry.categories << c
end

entry.content = content
entry.content["type"] = type if type

#puts entry.to_s

h = Atom::HTTP.new
h.user = username
h.pass = password
h.always_auth = :basic

c = Atom::Collection.new(base + "/posts", h)
res = c.post! entry

puts res.read_body
