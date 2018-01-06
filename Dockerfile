FROM ruby:2.3.3
RUN apt-get update && \
    apt-get install -qq -y build-essential nodejs libpq-dev postgresql-client --fix-missing --no-install-recommends

ENV INSTALL_PATH /app
RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH
ENV RAILS_ENV production

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install --deployment

COPY . .

RUN bundle exec rake DATABASE_URL=postgresql:does_not_exist assets:precompile

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
