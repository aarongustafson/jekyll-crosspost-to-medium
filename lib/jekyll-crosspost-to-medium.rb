#  By Aaron Gustafson, based on the work of Jeremy Keith
#  https://github.com/aarongustafson/jekyll-crosspost_to_medium
#  https://gist.github.com/adactio/c174a4a68498e30babfd
#  Licence : MIT
#
#  This generator cross-posts entries to Medium. To work, this script requires
#  a MEDIUM_USER_ID environment variable and a MEDIUM_INTEGRATION_TOKEN.
#
#  The generator will only pick up posts with the following front matter:
#
#  `crosspost_to_medium: true`
#
#  You can control crossposting globally by setting `enabled: true` under the
#  `jekyll-crosspost_to_medium` variable in your Jekyll configuration file.
#  Setting it to false will skip the processing loop entirely which can be
#  useful for local preview builds.

require 'json'
require 'net/http'
require 'net/https'
require 'kramdown'
require 'uri'

module Jekyll
  class MediumCrossPostGenerator < Generator
    safe true
    priority :low

    def generate(site)
      @site = site

      # puts "Kicking off cross-posting to Medium"
      @settings = @site.config['jekyll-crosspost_to_medium'] || []

      globally_enabled = @settings['enabled'] || true
      cache_dir = @settings['cache'] || @site.config['source'] + '/.jekyll-crosspost_to_medium'
      @crossposted_file = File.join(cache_dir, "medium_crossposted.yml")

      if globally_enabled
        # puts "Cross-posting enabled"
        user_id = ENV['MEDIUM_USER_ID'] or false
        token = ENV['MEDIUM_INTEGRATION_TOKEN'] or false

        if ! user_id or ! token
          raise ArgumentError, "MediumCrossPostGenerator: Environment variables not found"
          return
        end

        if defined?(cache_dir)
          FileUtils.mkdir_p(cache_dir)

          if File.exists?(@crossposted_file)
            crossposted = open(@crossposted_file) { |f| YAML.load(f) }
          else
            crossposted = []
          end

          # If Jekyll 3.0, use hooks
          if (Jekyll.const_defined? :Hooks)
            Jekyll::Hooks.register :posts, :post_render do |post|
              if ! post.published?
                next
              end

              crosspost = post.data.include? 'crosspost_to_medium'
              if ! crosspost or ! post.data['crosspost_to_medium']
                next
              end

              content = post.content
              url = "#{@site.config['url']}#{post.url}"
              title = post.data['title']

              crosspost_payload(crossposted, post, content, title, url)
            end
          else
            markdown_converter = @site.getConverterImpl(Jekyll::Converters::Markdown)
            @site.posts.each do |post|

              if ! post.published?
                next
              end

              crosspost = post.data.include? 'crosspost_to_medium'
              if ! crosspost or ! post.data['crosspost_to_medium']
                next
              end

              # Convert the content
              content = markdown_converter.convert(post.content)
              # Render any plugins
              content = (Liquid::Template.parse content).render @site.site_payload

              url = "#{@site.config['url']}#{post.url}"
              title = post.title

              crosspost_payload(crossposted, post, content, title, url)
            end
          end
        end
      end
    end


    def crosspost_payload(crossposted, post, content, title, url)
      # Update any absolute URLs
      content = content.gsub /href=(["'])\//, "href=\"\1#{@site.config['url']}/"
      content = content.gsub /src=(["'])\//, "src=\"\1#{@site.config['url']}/"

      # Save canonical URL
      canonical_url = url

      # Prepend the title and add a link back to originating site
      content.prepend("<h1>#{title}</h1>")
      # Append a canonical link and text
      # TODO Accept a position option, e.g., top, bottom.
      #
      # User the user's config if it exists
      if @settings['text']
          canonical_text = "#{@settings['text']}"
          canonical_text = canonical_text.gsub /{{ url }}/, canonical_url
      # Otherwise, use boilerplate
      else
          canonical_text = "<p><i>This article was originally posted <a href=\"#{url}\" rel=\"canonical\">on my own site</a>.</i></p>"
      end
      content << canonical_text

      # Strip domain name from the URL we check against
      url = url.sub(/^#{@site.config['url']}?/,'')

      # coerce tags to an array
      tags = post.data['tags']
      if tags.kind_of? String
        tags = tags.split(',')
      end

      # Only cross-post if content has not already been cross-posted
      if url and ! crossposted.include? url
        payload = {
          'title'         => title,
          'contentFormat' => "html",
          'content'       => content,
          'tags'          => tags,
          'publishStatus' => @settings['status'] || "public",
          'license'       => @settings['license'] || "all-rights-reserved",
          'canonicalUrl'  => canonical_url
        }

        crosspost_to_medium(payload)
        crossposted << url
        # Update cache
        File.open(@crossposted_file, 'w') { |f| YAML.dump(crossposted, f) }
      end
    end


    def crosspost_to_medium(payload)
      user_id = ENV['MEDIUM_USER_ID'] or false
      token = ENV['MEDIUM_INTEGRATION_TOKEN'] or false
      medium_api = URI.parse("https://api.medium.com/v1/users/#{user_id}/posts")

      # Build the connection
      https = Net::HTTP.new(medium_api.host, medium_api.port)
      https.use_ssl = true
      request = Net::HTTP::Post.new(medium_api.path)

      # Set the headers
      request['Authorization'] = "Bearer #{token}"
      request['Content-Type'] = "application/json"
      request['Accept'] = "application/json"
      request['Accept-Charset'] = "utf-8"

      # Set the payload
      request.body = JSON.generate(payload)

      # Post it
      response = https.request(request)

      if response.code == '201'
        puts "Posted '#{payload['title']}' to Medium (#{payload['publishStatus']})"
      else
        puts "Attempted to post '#{payload['title']}' to Medium. They responded #{response.body}"
      end
    end

  end
end
