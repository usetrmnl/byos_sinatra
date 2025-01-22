# Use the official lightweight Ruby image
FROM ruby:slim

# Install necessary packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    ruby-bundler \
    git \
    sqlite3 \
    pkg-config \
    libpq-dev && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Uncomment the next line to switch to sqlite
#ENV BYOS_DATABASE=sqlite

RUN bundle install 

# Copy the rest of the application code
COPY . .

RUN bundle exec rake db:setup 

# Expose the port that the application will run on
EXPOSE 4567

ENV APP_ENV=production

# Command to run the application
CMD ["bundle", "exec", "ruby", "app.rb", "-o", "0.0.0.0"]
