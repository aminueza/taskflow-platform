FROM ruby:3.2.2-alpine

# Install system dependencies
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    postgresql-client \
    tzdata \
    nodejs \
    git \
    curl \
    bash \
    tini

# Create non-root user
RUN addgroup -g 1001 -S rails \
    && adduser -S rails -u 1001 -G rails

WORKDIR /app

# Copy Gemfile first for better caching
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle config set --local without 'development test' \
    && bundle install --jobs=4 --retry=3 \
    && rm -rf ~/.bundle/ /usr/local/bundle/cache/*.gem

# Copy application code
COPY --chown=rails:rails . .

# Create necessary directories
RUN mkdir -p log tmp/pids tmp/cache tmp/sockets \
    && chown -R rails:rails log tmp db

# Set environment variables
ENV RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    BUNDLE_WITHOUT=development:test

# Switch to non-root user
USER rails

# Expose Puma port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Use tini for proper signal handling
ENTRYPOINT ["/sbin/tini", "--"]

# Start Puma server
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
