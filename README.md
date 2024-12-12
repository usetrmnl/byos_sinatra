# TRMNL BYOS - Ruby/Sinatra
with this project you can point a TRMNL (https://usetrmnl.com) device to your own server, either in the cloud or on your local network.

**requirements**

- TRMNL device
- TRMNL firmware (forked with new base url - your server)
- Ruby installed on your machine

**quickstart**

```
bundle # installs gems/libs
rake db:setup # creates db + Devices table
ruby app.rb # => runs server, visit http://localhost:4567
```

**debugging / building**

first access the console: `rake console`

```
Device.count # => 0 (interact with db ojects via ActiveRecord ORM)
ScreenFetcher.call (fetch upcoming render)
ScreenGenerator.new("<p>Some HTML here</p>").process # => creates img in /public/images/generated
```