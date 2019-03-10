require 'active_support/core_ext/string'
require 'cgi'
require 'nokogiri'
require 'time'

DIR = "3d2d5cffaf2f88acc50f3b71858c4fdd500503305fb46f4c4a5abf661bb3a931"

posts_xml = Nokogiri::XML(File.read("./ingest/#{DIR}/posts/posts.xml"))

TITLE_ELEMENTS = %w{regular-title link-text conversation-title}

posts_xml.css("posts").children.each do |post|
  id = post['id']

  date = Time.parse post['date-gmt']
  title_element_name = TITLE_ELEMENTS.detect do |en|
    post.css(en).length > 0
  end

  title = post.css(title_element_name).text

  if title_element_name.nil?
    title = post['slug'].
              gsub('-', ' ').
              gsub('view on path', '').
              titleize.
              strip

    title = date.getlocal.to_s if title.empty?
  end

  kind = nil
  body = nil

  if (body_el = post.css('regular-body')).length > 0
    kind = 'regular'
    body = CGI.unescapeHTML post.css('regular-body').text
  elsif (convo_el = post.css('conversation')).length > 0
    kind = 'conversation'
    convo = convo_el.css('line').map do |line|
      "<dt>#{CGI.unescapeHTML line['label']}</dt>\n<dd>#{CGI.unescapeHTML line.text}</dd>"
    end.join("\n")
    body = "<dl>\n#{convo}\n</dl>"
  elsif (photo_url_els = post.css('photo-url')).length > 0
    kind = 'photo'
    media = Dir.glob("./ingest/#{DIR}/media/#{id}*")
    body = media.map do |m|
      m.inspect
    end
  elsif (quote_el = post.css('quote-text')).length > 0
    kind = 'quote'
    quote_source_el = post.css('quote-source')
    body = "<blockquote>#{CGI.unescapeHTML quote_el.text}</blockquote>\n<cite>#{CGI.unescapeHTML quote_source_el.text}</cite>"
  else
    kind = 'unknown'
    body = "<pre>#{CGI.escapeHTML post.to_xml}</pre>"
  end

  fm = <<EOM
---
layout: #{kind}
title: #{title.inspect}
date: #{date.iso8601}
---
EOM

  filename = "./_posts/#{date.strftime('%Y-%m-%d')}-#{title.dasherize}.html"

  File.open(filename, 'w') do |f|
    f.write fm
    f.write "{% raw %}"
    f.write body
    f.write "{% endraw %}"
  end

end
