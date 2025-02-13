#!/bin/sh
bundle exec rake db:prepare
exec "$@"
