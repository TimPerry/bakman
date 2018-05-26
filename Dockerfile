FROM ruby:2.5

RUN apt-get update && apt install -y p7zip-full rsync
RUN bundle config --global frozen 1

WORKDIR /bakman

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . /bakman

CMD "ruby /bakman/run_backup.rb"
