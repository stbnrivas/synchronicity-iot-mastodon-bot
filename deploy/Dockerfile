FROM ruby:2.6.3
LABEL MAINTAINER BikeIn Team

RUN mkdir /bot
COPY Gemfile Gemfile.lock /bot/
RUN apt-get update -qq \
  && apt-get install -y \
        build-essential \
        ruby-dev \
        # bundler \
        ghostscript \
        libgs-dev \
        imagemagick \
  && gem install bundler:2.0.2 \
  && cd /bot \
  && bundle install
COPY . /bot

WORKDIR /bot
CMD ["bundle","exec","ruby","worker.rb"]
