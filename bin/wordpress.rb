#!/usr/bin/env ruby
require 'net/http'
require 'rubygems'
require 'atom/entry' # sudo gem install atom-tools
require 'atom/collection'
require 'trollop' # gem
require 'yaml'
require 'fcntl'
require 'pp'

opts = Trollop::options do
  version "wordpres 0.0.1 (c) 2009 Nate Murray"
  banner <<-EOS
wordpress - edit a wordpress blog the cli

original by John Mettraux
http://jmettraux.wordpress.com/2007/11/05/posting-to-wordpress-via-ruby-and-atompub/

Usage: #{$0} [options] content
where [options] are:
EOS
  opt :category, "tag/category. specify multiple times for multiple categories", :type => String, :multi => true
  opt :title,    "title for the post", :required => true
  opt :type,     "type of the content [html|xhtml|text]", :default => 'html', :type => String
  opt :config,   "path to config file containing blog specifications", :default => File.expand_path('~/.wordpressrb.yml'), :type => String
  opt :blog,     "short name of the blog to use", :default => 'default'
  opt :verbose,  "verbose", :default => false
  opt :dry,      "dry run", :default => false
end
Trollop::die :type, "type must be one of [html|xhtml|text]" unless opts[:type] =~ /^(x?html|text)$/i
Trollop::die :config, "#{opts[:config]} does not exist. Please create that file. See config/wordpressrb.yml.example" unless File.exists?(opts[:config])

blog_configs = YAML.load_file(opts[:config])
Trollop::die :blog, "#{opts[:blog]} does not exist in #{opts[:config]}" unless blog_configs.has_key?(opts[:blog])

config = blog_configs[opts[:blog]]
%w{ author_name blog_name blog_uri endpoint_uri user_name password }.each do |k|
  Trollop::die :config, "#{opts[:config]} blog #{opts[:blog]} does not contain a value for #{k}." unless config.has_key?(k)
end

opts[:category] ||= []

content = begin
  if STDIN.fcntl(Fcntl::F_GETFL, 0) == 0
    STDIN.read
  else
    ARGV[1..-1].join(" ")
  end
end

# create entry
entry = Atom::Entry.new
entry.title = opts[:title]
entry.updated!

author = Atom::Author.new
author.name = config['author_name']
author.uri = config['blog_uri']
entry.authors << author

opts[:category].each do |t|
    c = Atom::Category.new
    c["scheme"] = config['blog_uri']
    c["term"] = t.strip
    entry.categories << c
end

entry.content = content
entry.content["type"] = opts[:type] if opts[:type]

puts entry.to_s if opts[:verbose] || opts[:dry]
exit if opts[:dry]

h = Atom::HTTP.new
h.user = config['user_name']
h.pass = config['password']
h.always_auth = :basic

c = Atom::Collection.new(config['endpoint_uri'] + "/posts", h)
res = c.post! entry

puts res.read_body
