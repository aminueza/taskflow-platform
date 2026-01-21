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
RUN bundle config set --local without 'development test' \
    && bundle install --jobs=4 --retry=3 \
    && rm -rf ~/.bundle/ /usr/local/bundle/cache/*.gem \
    && find /usr/local/bundle/gems/ -name "*.c" -delete \
    && find /usr/local/bundle/gems/ -name "*.o" -delete

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

# Copy installed gems from dependencies stage
COPY --from=dependencies /usr/local/bundle /usr/local/bundle

# Set bundle path explicitly
ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=development:test \
    BUNDLE_DEPLOYMENT=false \
    GEM_HOME=/usr/local/bundle \
    PATH="/usr/local/bundle/bin:$PATH"

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
