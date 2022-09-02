FROM ruby:2.7

RUN apt-get update \
  && apt-get install -y \
    git \
    locales \
    make \
    nodejs

COPY . /src/gh/pages-gem

RUN \
  gem install bundler && \
  bundle config local.github-pages /src/gh/pages-gem && \
  bundle install --gemfile=/src/gh/pages-gem/Gemfile

RUN \
  echo "en_US UTF-8" > /etc/locale.gen && \
  locale-gen en-US.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

WORKDIR /src/site

EXPOSE 4000

CMD ["bundle", "exec", "jekyll", "serve", "-H", "0.0.0.0", "-P", "4000", "--drafts", "--future"]
