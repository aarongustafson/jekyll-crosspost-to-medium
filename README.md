# Crosspost to Medium Generator for Jekyll and Octopress

This plugin makes it possible to automatically syndicate your posts to [Medium](https://medium.com) from your Jekyll and Octopress projects.

## Setup

1. [Sign up for a Medium account](https://medium.com/m/signin?redirect=https%3A%2F%2Fmedium.com%3A443%2F) (if you don’t already have one). Log in.
2. Go to [your settings page](https://medium.com/me/settings) and look for "Integration Tokens". Generate one. Save it to your [Environment Variables](https://en.wikipedia.org/wiki/Environment_variable) as MEDIUM_INTEGRATION_TOKEN.
3. Visit `https://api.medium.com/v1/me?accessToken=`, adding your Integration Token to the end of that URL
4. Grab the id from the JSON provided and save that to your [Environment Variables](https://en.wikipedia.org/wiki/Environment_variable) as MEDIUM_USER_ID.
5. Copy `crosspost_to_medium.rb` to your site’s `plugins` folder.

## Crossposting

Add `crosspost_to_medium: true` to the front matter for any post you would like to crosspost to Medium.

Crossposted files will be logged in `.cache/medium_crossposted.yml`, so make sure that file gets checked into your Git repo if you work from multiple computers. That will enssure you never crosspost an entry more than once.

You can control crossposting globally by setting the same variable in your Jekyll configuration file. Setting it to false will skip the processing loop entirely, which can be useful for local preview builds.

## A Note on Envitronment Variables

If you are having problems setting up Environment Variables, check out these guides:

* [Linux](https://www.digitalocean.com/community/tutorials/how-to-read-and-set-environmental-and-shell-variables-on-a-linux-vps)
* [Mac](http://osxdaily.com/2015/07/28/set-enviornment-variables-mac-os-x/) (For a GUI, check out [EnvPane](https://github.com/hschmidt/EnvPane))
* [Windows](http://www.computerhope.com/issues/ch000549.htm)

## Credits

Many thanks to Jeremy Keith for [sharing his process](https://adactio.com/journal/9694) (and [PHP code](https://gist.github.com/adactio/c174a4a68498e30babfd)) for getting this working on his own site.