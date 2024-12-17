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

**deploying**

to run TRMNL on your local network only:

1. run app in production mode (`ruby app.rb -e production`)
2. retrieve your machine's local IP, ex 192.168.x.x (Mac: `ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk '{print $2}'`)
3. confirm it works by visiting `http://192.168.x.x:4567/devices` from any device also on the network
4. point your [forked FW's](https://github.com/usetrmnl/firmware) `API_BASE_URL` ([source](https://github.com/usetrmnl/firmware/blob/2ee0723c66a3468b969c83d7663ffb3f8322ad99/include/config.h#L56)) to `http://192.168.x.x:4567`

to run TRMNL on a cloud server:

TBD
