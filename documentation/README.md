![Mastodon](https://i.imgur.com/NhZc40l.png)
====

View the documentation at <https://docs.joinmastodon.org>

### Build/Deploy

#### Requires
* Hugo\ 
(on macOS: `brew install hugo`\
 windows: `choco install hugo -confirm`\
 linux: `apt-get install hugo` OR `snap install hugo`)


#### build the static site
`hugo -D` 

Output will be in `./public/` 

TODO clean up the ad hoc quick and dirty doc copy, for now:

```bash
cp ./public/* ../public/docs
cp ../public/docs/*{.svg,.png} ../public
mv ../public/docs/assets/ ../public/assets
cp ../public/docs/docs/* ../public/docs
```

This hack will copy the static files into ../public/docs, and then copy the ./public/docs/ folder content into ../public/docs as well so we can route to the static files properly (There is 100% an easy fix that will allow for this hack to be removed, but for now it works.)




cp -R ./public/* /Users/Guava/Documents/ASU/Research/BRIDGES/asdf/mastodon/public/docs
cp -R /Users/Guava/Documents/ASU/Research/BRIDGES/asdf/mastodon/public/docs/*{.svg,.png} /Users/Guava/Documents/ASU/Research/BRIDGES/asdf/mastodon/public/
mv /Users/Guava/Documents/ASU/Research/BRIDGES/asdf/mastodon/public/docs/assets/ /Users/Guava/Documents/ASU/Research/BRIDGES/asdf/mastodon/public/assets
cp -R /Users/Guava/Documents/ASU/Research/BRIDGES/asdf/mastodon/public/docs/docs/* /Users/Guava/Documents/ASU/Research/BRIDGES/asdf/mastodon/public/docs

cp -R ./public/* /usr/local/var/www/docs
cp -R /usr/local/var/www/docs/*{.svg,.png} /usr/local/var/www/
mv /usr/local/var/www/docs/assets/ /usr/local/var/www/assets
cp -R /usr/local/var/www/docs/docs/* /usr/local/var/www/docs

