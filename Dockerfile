FROM ruby:2.6
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
    nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

ENV INSTALL_PATH /usr/local/transition
RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

# set rails environment
ARG RAILS_ENV
ENV RAILS_ENV=${RAILS_ENV:-production}
ENV RACK_ENV=${RAILS_ENV:-production}

COPY Gemfile $INSTALL_PATH/Gemfile
COPY Gemfile.lock $INSTALL_PATH/Gemfile.lock

RUN gem update --system
RUN gem install bundler

# bundle ruby gems based on the current environment, default to production
RUN echo $RAILS_ENV
RUN \
  if [ "$RAILS_ENV" = "production" ]; then \
    bundle install --without development test --jobs 4 --retry 10; \
  else \
    bundle install --jobs 4 --retry 10; \
  fi

COPY . $INSTALL_PATH

# Plek (GDS path finder gem) raises an error when initialized with production
# Since we don't intend on using it, we can set a dummy value.
ARG GOVUK_APP_DOMAIN
ENV GOVUK_APP_DOMAIN=${GOVUK_APP_DOMAIN:-localhost}

# precompile assets for production
RUN \
  RAILS_ENV=production \
  bin/rails DATABASE_URL=postgresql:does_not_exist assets:precompile

EXPOSE 3000
CMD ["rails", "server"]
