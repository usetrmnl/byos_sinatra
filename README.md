# Docs TBD

quickstart

```
rake db:setup
```

```
rake console

Device.count # => 0
ScreenFetcher.call
ScreenGenerator.new("<p>Some HTML here</p>").process # => img will be created in `public/images/generated`
```