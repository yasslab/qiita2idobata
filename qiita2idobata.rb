#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'rss'
require 'idobata'
require 'pry'

Idobata.hook_url = ENV['IDOBATA_END']

msg = ""

# NOTE: This script uses YassLab organization as an example.
#       Replace 'yasslab' with your own organization name.
# Flush cache RSS before downloading
`curl -H 'Pragma: no-cache' -L qiita.com/organizations/yasslab/activities.atom`

rss = RSS::Parser.parse("https://qiita.com/organizations/yasslab/activities.atom", false)

# NOTE: Heroku Scheduler's frequency should be set to "Every 10 minutes"
articles = rss.items.select do |item|
  #(Time.now - item.published.content) / 60 <= 10000 # for debugging
  (Time.now - item.published.content) / 60 <= 10
end

msg << articles.map {|a|
  p "New article is posted by <span class='label label-info'>#{a.author.name.content}</span><br /> <b><a href='#{a.link.href}'>#{a.title.content}</a></b>"
}.join("<br/>")

Idobata::Message.create(source: msg, format: :html) unless msg.empty?
