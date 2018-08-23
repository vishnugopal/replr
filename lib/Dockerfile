FROM ruby:2.3.1-alpine
ADD Gemfile /app/
RUN apk --update add --virtual build-dependencies ruby-dev build-base && \
  gem install bundler --no-ri --no-rdoc && \
  cd /app ; bundle install --without development test && \
  apk del build-dependencies
ADD . /app
ENV RACK_ENV production
WORKDIR /app
CMD ["/usr/local/bundle/bin/bundle", "exec", "irb"]
