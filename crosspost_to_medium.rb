#  By Aaron Gustafson, based on the work of Jeremy Keith
#  https://github.com/aarongustafson/jekyll-crosspost_to_medium 
#  https://gist.github.com/adactio/c174a4a68498e30babfd
#  Licence : MIT
#  
#  This generator cross-posts entries to Medium. To work, this script
#  requires a MEDIUM_USER_ID environment variable and a 
#  MEDIUM_INTEGRATION_TOKEN. 
#
#  The generator will only pick up posts with the following front matter:
#
#   crosspost_to_medium: true

require 'json'
require 'net/http'
require 'net/https'
require 'kramdown'
require 'uri'

MEDIUM_CACHE_DIR = File.expand_path('../../.cache', __FILE__)
FileUtils.mkdir_p(MEDIUM_CACHE_DIR)

module Jekyll
  
  class MediumCrossPostGenerator < Generator
    safe true
    priority :low
    
    def generate(site)

      user_id = ENV['MEDIUM_USER_ID'] or false
      token = ENV['MEDIUM_INTEGRATION_TOKEN'] or false

      if ! user_id or ! token
        return
      end
      
      if defined?(MEDIUM_CACHE_DIR)
        
        crossposted_file = File.join(MEDIUM_CACHE_DIR, "medium_crossposted.yml")
        if File.exists?(crossposted_file)
          crossposted = open(crossposted_file) { |f| YAML.load(f) }
        else
          crossposted = []
        end
        
        site.posts.each do |post|
          
          if ! post.published?
            next
          end

          crosspost = post.data.include? "crosspost_to_medium"
          if ! crosspost or ! post.data["crosspost_to_medium"]
            next
          end

          # Get the URL
          url = "#{site.config['url']}#{post.url}"
          
          # Content
          content = post.content
          content = Kramdown::Document.new(content).to_html
          content.prepend("<h1>#{post.title}</h1>")
          content << "<p><i>This was originally posted <a href=\"#{url}\" rel=\"canonical\">on my own site</a>.</i></p>"

          # Only proceed if it has not been cross-posted
          if url and ! crossposted.include? url

            payload = {
            	'title'			=> post.title,
            	'contentFormat'	=> "html",
            	'content'		=> content,
            	'tags'			=> post.data["categories"],
            	'canonicalUrl'	=> url
            }

            # Both Facebook & LinkedIn
            crosspost_to_medium( payload )
            
            crossposted << url

          end

        end
        
        # Save it back
        File.open(crossposted_file, 'w') { |f| YAML.dump(crossposted, f) }

      end

    end

    def crosspost_to_medium( payload )

    	puts "Cross-posting #{payload['title']} to Medium"

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

    end

  end
  
end