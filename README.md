# TRMNL BYOS - Ruby/Sinatra

with this project you can point a TRMNL device (https://usetrmnl.com) to your own server, either in the cloud or on your local network.

**requirements**

- TRMNL device
- TRMNL firmware (forked with new base url - your server)
- Ruby installed on your machine (or Docker)

**quickstart**

```
cp dotenv-sample .env # (edit to set desired values)
bundle # installs dependencies
rake db:setup # creates database
ruby app.rb # runs server, visit http://localhost:4567/devices/new
```

**docker-based setup**
You may optionally edit the Dockerfile to enable sqlite.

```
cp dotenv-sample .env # (and edit to set the appropriate variables)
docker build -t trmnl_byos -f Dockerfile .
docker run --name trmnl -p 4567:4567 trmnl_byos
```

**debugging / building**

first access the console: `rake console`

```
Device.count # => 0 (interact with db object via ActiveRecord ORM)
ScreenFetcher.call # fetches upcoming render, sorts desc by created timestamp
ScreenGenerator.new("<p>Some HTML here</p>").process # => creates img in /public/images/generated
```

**deploying**

on your local network:

1. set `BASE_URL` inside the file `.env` to where this is hosted (eg `http://192.168.x.x:4567`, no trailing slash)
2. run app in production mode (`ruby app.rb`)
3. retrieve your machine's local IP, ex 192.168.x.x (Mac: `ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk '{print $2}'`)
4. confirm it works by visiting `http://192.168.x.x:4567/devices` from any device also on the network
5. point your [forked FW's](https://github.com/usetrmnl/firmware) `API_BASE_URL` ([source](https://github.com/usetrmnl/firmware/blob/2ee0723c66a3468b969c83d7663ffb3f8322ad99/include/config.h#L56)) to same value as `BASE_URL`

in the cloud:

TBD
