Gem::Specification.new do |s|
  s.name        = 'jekyll-crosspost-to-medium'
  s.version     = '0.1.14'
  s.date        = '2016-04-15'
  s.summary     = "Crosspost to Medium Generator for Jekyll"
  s.description = <<-EOF
  This generator cross-posts entries to Medium. To work, this script requires
  a MEDIUM_USER_ID environment variable and a MEDIUM_INTEGRATION_TOKEN.

  The generator will only pick up posts with the following front matter:

  `crosspost_to_medium: true`

  You can control crossposting globally by setting `enabled: true` under the 
  `jekyll-crosspost_to_medium` variable in your Jekyll configuration file.
  Setting it to false will skip the processing loop entirely which can be
  useful for local preview builds.
EOF
  s.authors     = ["Aaron Gustafson"]
  s.email       = 'aaron@easy-designs.net'
  s.files       = ["lib/jekyll-crosspost-to-medium.rb"]
  s.homepage    = 'http://rubygems.org/gems/jekyll-crosspost-to-medium'
  s.license     = 'MIT'

  s.add_runtime_dependency "jekyll", ">= 2.0", "< 4.0"
  s.add_runtime_dependency "json", "~> 2.0"
  s.add_runtime_dependency "http", "~> 2.0"
end