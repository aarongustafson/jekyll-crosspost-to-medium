# Crosspost to Medium Generator for Jekyll and Octopress

This plugin makes it possible to automatically syndicate your posts to [Medium](https://medium.com) from your Jekyll and Octopress projects.

## Setup

1. [Sign up for a Medium account](https://medium.com/m/signin?redirect=https%3A%2F%2Fmedium.com%3A443%2F) (if you don’t already have one). Log in.
2. Go to [your settings page](https://medium.com/me/settings) and look for "Integration Tokens". Generate one. Save it to your [Environment Variables](https://en.wikipedia.org/wiki/Environment_variable) as MEDIUM_INTEGRATION_TOKEN.
3. Visit `https://api.medium.com/v1/me?accessToken=`, adding your Integration Token to the end of that URL
4. Grab the id from the JSON provided and save that to your [Environment Variables](https://en.wikipedia.org/wiki/Environment_variable) as MEDIUM_USER_ID.
5. Copy `jekyll-crosspost-to-medium.rb` to your site’s `plugins` folder.

## Installation

This plugin can be installed in two ways:

1. As a Ruby Gem: 
    1. `gem install jekyll-crosspost-to-medium`
    2. Add an `ext.rb` file to your `plugins` directory (or edit your existing one)
    3. Add `require 'jekyll-crosspost-to-medium'`
2. By copying `jekyll-crosspost-to-medium.rb` (found in the `lib` directory) into your `plugins` directory.

## Crossposting

Add `crosspost_to_medium: true` to the front matter of any post you would like to crosspost to Medium.

## Configuation

This plugin takes a number of configuration options. These allow you to customise how the plugin works and what metadata is included when you syndicate to Medium. The following options are available:

```yaml
jekyll-crosspost_to_medium:
  enabled: true | false
  cache: .jekyll-crosspost_to_medium
  status: public | draft | unlisted
  license: all-rights-reserved | cc-40-by | cc-40-by-sa | cc-40-by-nd | cc-40-by-nc | cc-40-by-nc-nd | cc-40-by-nc-sa | cc-40-zero | public-domain
```

* `enabled`

    Default: `true`

    Controls crossposting globally. Setting this to false will skip the processing loop entirely which can be useful for local preview builds.

* `cache`

    Default: `[source directory]/.jekyll-crosspost_to_medium`

    The name of the diretory where crossposted files will be logged. Make sure this file gets checked into your Git repo if you work from multiple computers. This will ensure you never crosspost an entry more than once.

* `status`

    Default: `public`

    The status your post is given when it is syndicated to Medium.

* `license`

    Default: `all-rights-reserved`

    The license your post is given when it is syndicated to Medium.

## A Note on Environment Variables

If you are having problems setting up Environment Variables, check out these guides:

* [Linux](https://www.digitalocean.com/community/tutorials/how-to-read-and-set-environmental-and-shell-variables-on-a-linux-vps)
* [Mac](http://osxdaily.com/2015/07/28/set-enviornment-variables-mac-os-x/) (For a GUI, check out [EnvPane](https://github.com/hschmidt/EnvPane))
* [Windows](http://www.computerhope.com/issues/ch000549.htm)

## Credits

Many thanks to Jeremy Keith for [sharing his process](https://adactio.com/journal/9694) (and [PHP code](https://gist.github.com/adactio/c174a4a68498e30babfd)) for getting this working on his own site.
