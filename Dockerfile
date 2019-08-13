FROM ruby:2.6
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
    nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean
WORKDIR /usr/local/transition
COPY . .
RUN bundle install
RUN bundle exec rake assets:precompile
EXPOSE 9292
CMD ["puma"]
