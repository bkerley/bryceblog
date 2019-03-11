require 'active_support/core_ext/string'
require 'cgi'
require 'fileutils'
require 'nokogiri'
require 'time'
require 'yaml'

DIR = "3d2d5cffaf2f88acc50f3b71858c4fdd500503305fb46f4c4a5abf661bb3a931"
POST_IMAGE_DIR = "assets/post_images"

FileUtils.mkdir_p POST_IMAGE_DIR

posts_xml = Nokogiri::XML(File.read("./ingest/#{DIR}/posts/posts.xml"))

TITLE_ELEMENTS = %w{regular-title link-text conversation-title}

posts_xml.css("posts").children.each do |post|
  fm = {
    layout: 'post'
  }

  id = post['id']

  date = Time.parse post['date-gmt']
  fm['date'] = date.iso8601

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

  fm['title'] = title

  kind = nil
  body = nil
  fm['tags'] = post.css('tag').map{ |t| t.text }

  fm['redirect_from'] = [post['url'], post['url-with-slug']]
                    .compact
                    .map do |u|
    URI(u).path
  end

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
      FileUtils.cp(m, POST_IMAGE_DIR)
      "<img src=\"/#{POST_IMAGE_DIR}/#{File.basename(m)}\" />"
    end.join("<br />\n")
  elsif (quote_el = post.css('quote-text')).length > 0
    kind = 'quote'
    quote_source_el = post.css('quote-source')
    body = "<blockquote>#{CGI.unescapeHTML quote_el.text}</blockquote>\n<cite>#{CGI.unescapeHTML quote_source_el.text}</cite>"
  elsif (link_url_el = post.css('link-url')).length > 0
    kind = 'link'
    link_text = post.css('link-text').text || link_url_el.text
    link_desc = CGI.unescapeHTML post.css('link-description').text
    body = <<EOB
<a href="#{link_url_el.text}">#{link_text}</a>
<p>#{link_desc}</p>
EOB
  else
    kind = 'unknown'
    body = "<pre>#{CGI.escapeHTML post.to_xml}</pre>"
  end

  fm['kind'] = kind

  filename = "./_posts/#{date.strftime('%Y-%m-%d')}-#{title.dasherize}.html"

  File.open(filename, 'w') do |f|
    f.write YAML.dump fm.stringify_keys
    f.puts '---'
    f.write "{% raw %}"
    f.write body.gsub("\n\n", "{% endraw %}\n\n{% raw %}")
    f.write "{% endraw %}"
  end

end
