FROM ruby:2.5.1
RUN apt-get update && \
    apt-get install -qq -y build-essential libpq-dev postgresql-client --fix-missing --no-install-recommends

RUN apt-get install -y libidn11-dev

RUN curl -SL https://deb.nodesource.com/setup_10.x | bash
RUN apt-get install -y nodejs

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update && apt-get install -y yarn


ENV INSTALL_PATH /app
RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH
ENV RAILS_ENV production

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install --deployment

COPY . .

RUN bundle exec rails DATABASE_URL=postgresql:does_not_exist assets:precompile

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
