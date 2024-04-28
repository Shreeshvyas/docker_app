# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
# ARG RUBY_VERSION=3.0.6
# FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

# Rails app lives here
# WORKDIR /rails

# Set production environment
# ENV RAILS_ENV="production" \
#     BUNDLE_DEPLOYMENT="1" \
#     BUNDLE_PATH="/usr/local/bundle" \
#     BUNDLE_WITHOUT="development"


# Throw-away build stage to reduce size of final image
# FROM base as build

# Install packages needed to build gems
# RUN apt-get update -qq && \
    # apt-get install --no-install-recommends -y build-essential git libpq-dev libvips pkg-config

# Install application gems
# COPY Gemfile Gemfile.lock ./
# RUN bundle install && \
#     rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
#     bundle exec bootsnap precompile --gemfile

# Copy application code
# COPY . .

# Precompile bootsnap code for faster boot times
# RUN bundle exec bootsnap precompile app/ lib/

# Adjust binfiles to be executable on Linux
# RUN chmod +x bin/* && \
#     sed -i "s/\r$//g" bin/* && \
#     sed -i 's/ruby\.exe$/ruby/' bin/*


# Final stage for app image
# FROM base

# Install packages needed for deployment
# RUN apt-get update -qq && \
#     apt-get install --no-install-recommends -y curl libvips postgresql-client && \
#     rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy built artifacts: gems, application
# COPY --from=build /usr/local/bundle /usr/local/bundle
# COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
# RUN useradd rails --create-home --shell /bin/bash && \
#     chown -R rails:rails db log storage tmp
# USER rails:rails

# Entrypoint prepares the database.
# ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
# EXPOSE 3000
# CMD ["./bin/rails", "server"]

# FROM ruby:3.0.6

# # Install dependencies
# RUN apt-get update && apt-get install -y \
#     build-essential \
#     nodejs \
#     postgresql-client \
#     && rm -rf /var/lib/apt/lists/*

# # Set working directory
# WORKDIR /rails

# # Copy Gemfile and Gemfile.lock
# COPY Gemfile Gemfile.lock ./

# # Install gems
# RUN bundle install

# # Copy application code
# COPY . .

# EXPOSE 3000
# CMD ["./bin/rails", "server"]

# Use an official Ruby image as a base
FROM ruby:3.0.6

# Set the working directory in the container
WORKDIR /app

# Install dependencies
RUN apt-get update && \
    apt-get install -y nodejs && \
    gem install bundler

# Copy the Gemfile and Gemfile.lock from your Rails application directory into the container
COPY Gemfile Gemfile.lock ./

# Install Ruby dependencies
RUN bundle install

# Copy the rest of the application code into the container
COPY . .

#Master Key
ENV RAILS_MASTER_KEY=cc77a8cacca59c2caaea525b98a514a9

# Expose port 3000 to the outside world
EXPOSE 3000

# Configure database connection settings
ENV DATABASE_URL=postgresql://postgres:postgres@db/demo_app_production

# Run any necessary database migrations or setup tasks
RUN bundle exec rails db:create db:migrate RAILS_ENV=production

# Start the Rails server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
