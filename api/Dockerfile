FROM ruby:3.2.2-alpine AS base

RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    tzdata \
    nodejs \
    yarn \
    git \
    curl \
    bash

WORKDIR /app

FROM base AS dependencies

COPY Gemfile Gemfile.lock ./
RUN bundle config set --local deployment 'true' \
    && bundle config set --local without 'development test' \
    && bundle install --jobs=4 --retry=3 \
    && rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

FROM ruby:3.2.2-alpine AS release

RUN apk add --no-cache \
    postgresql-client \
    tzdata \
    bash \
    tini \
    curl

RUN addgroup -g 1001 -S rails \
    && adduser -S rails -u 1001 -G rails

WORKDIR /app
    
COPY --from=dependencies /usr/local/bundle /usr/local/bundle

COPY --chown=rails:rails . .

# RUN RAILS_ENV=production bundle exec rails assets:precompile

RUN mkdir -p log tmp/pids tmp/cache tmp/sockets \
    && chown -R rails:rails log tmp

# Switch to non-root user
USER rails

# Expose Puma port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Use tini for proper signal handling
ENTRYPOINT ["/sbin/tini", "--"]

# Start Puma server
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
