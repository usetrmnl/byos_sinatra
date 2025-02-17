# Use the official lightweight Ruby image
FROM ruby:3.4.2-slim

# Install necessary packages
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    build-essential \
    ruby-bundler \
    git \
    sqlite3 \
    pkg-config \
    firefox-esr \
    imagemagick \
    libyaml-dev \
    && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock .ruby-version ./

RUN bundle install 

# Copy the rest of the application code
COPY . .

VOLUME /app/db/sqlite 

# Expose the port that the application will run on
EXPOSE 4567

ENTRYPOINT ["/app/entrypoint.sh"]

# Command to run the application
CMD ["bundle", "exec", "ruby", "app.rb", "-o", "0.0.0.0"]
