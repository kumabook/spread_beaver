# spread_beaver

[![Build Status](https://travis-ci.org/kumabook/spread_beaver.svg?branch=master)](https://travis-ci.org/kumabook/spread_beaver)
[![Coverage Status](https://coveralls.io/repos/github/kumabook/spread_beaver/badge.svg?branch=master)](https://coveralls.io/github/kumabook/spread_beaver?branch=master)
<a href="https://codeclimate.com/github/kumabook/spread_beaver"><img src="https://codeclimate.com/github/kumabook/spread_beaver/badges/gpa.svg" /></a>

## Overview

spread_beaver is a news, videos and tracks
aggregation api server written in rails.

It contains these feature:
- API Server for mobile app: iOS (and Android). HTTP Routing: `/v3/*`
- HTML based manage app for administrator. HTTP Routing: `/*`
- Crawler to RSS feeds and tracks. It's a rake task: `rake crawl`
  - Currenly RSS feeds crawler uses [Feedly Cloud API](https://developer.feedly.com/)
  - Tracks crawler uses [pink-spider](https://github.com/kumabook/pink-spider)


## Resource ids

Feed, Category, Tag, Genre, and Playlist are used as stream resource.

- Feed is a RSS feed
- Category classifies Feed (Subscription)
- Tag classifies Entry
- (Genre classifies Track)
- (Playlist contains track collections that is created by user or generated automatically)

The format of these ids are:

- Feed Id
  - `feed/:url`
  - example: `feed/http://feeds.engadget.com/weblogsinc/engadget`
- Category Id
  - `user/:userId/category/:label`
  - example: `user/c805fcbf-3acf-4302-a97e-d82f9d7c897f/category/tech`
- Tag Id
  - `user/:userId/tag/:label`
  - example: `user/c805fcbf-3acf-4302-a97e-d82f9d7c897f/tag/inspiration`
- (Genre Id)
  - `genre/:label`
- (Playlist Id)
  - `user/:userId/playlist/:label`

## Global Resource Ids

Global resource is generated implicitly.


- `user/:userId/category/global.all`
- `user/:userId/tag/global.saved`.
- `user/:userId/playlist/global.liked`.

Originally, Feedly Cloud API is only for user related resource. However, we add extended shared global resources:

- `tag/global.latest`
- `tag/global.popular` ... It takes `newer_than` and `older_than` params
- `playlist/global.latest`
- `playlist/global.popular` ... It takes `newer_than` and `older_than` params

## List of API

Some api are compatible with Feedly Cloud API (Response format, resource id).

See [Feedly Cloud API document](https://developer.feedly.com/v3/)


- [Profile API and Authentication API|Profile API](doc/profile_api.md)
- [Feeds API](doc/feeds_api.md)
- [Entries API](doc/entries_api.md)
- [Streams API](doc/streams_api.md)
  - Entry Streams (same as Feedly Cloud API)
  - Track Streams (Customized API)
- [Tracks API](doc/tracks_api.md)
- [Markers API](doc/markers_api.md)
- [Subscriptions API](doc/subscriptions_api.md)
- [Categories API](doc/categories_api.md)
- [Topics API](doc/topics_api.md) (Customized API)
- [Tags API](doc/tags_api.md)
- [Keywords API](doc/keywords_api.md)
- [Playlists API](doc/playlists_api.md)

## How to build and deploy

### Running locally

- Prerequisites:
  - ruby (2.5.1)
  - nodejs (6.0.0+)
  - yarn (0.25.2+)
  - postgres (10.3+)
  - redis (3.2+)
- Run  `bundle install`
- Create `config/database.yml` from `config.database.yml.dist` and change it if need
- Run `rake db:create`
- Run `rake db:migrate`
- Run `rake db:seed`
- Run `rails s`

### Running on docker

- Install `docker` and `docker-compose` and `docker-machine`
  - `brew install docker docker-compose docker-machine`
- Create container and prepare db
  - `cp .env.dist .env`
  - `cp .env.pink_spider.dist .env.pink_spider`
  - `docker-compose up`
  - `docker-compose run --rm web bundle exec rails db:create`
  - `docker-compose run --rm web bundle exec rails db:migrate`
  - `docker-compose run --rm pink_spider bundle exec rake db:create`
  - `docker-compose run --rm pink_spider bundle exec rake db:migrate`
- Restore database from backup
  - `heroku pg:backups:capture --app $APP`
  - `heroku pg:backups:download --app $APP -o spread_beaver.dump`
  - `cat spread_beaver.dump | docker exec -i `docker-compose ps -q db` pg_restore --verbose  --clean --no-acl --no-owner -U postgres -d spread_beaver_development`
  - `heroku pg:backups:capture --app $PINK_SPIDER_APP`
  - `heroku pg:backups:download --app $PINK_SPIDER_APP -o pink_spider.dump`
  - `cat pink_spider.dump | docker exec -i `docker-compose ps -q db` pg_restore --verbose --clean --no-acl --no-owner -U postgres -d pink_spider_production`
- Clear cache
  - `docker-compose run --rm web bundle exec rails r 'Rails.cache.clear'`

### Deploying on Heroku

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

- After deployment, open scheculer page by `heroku addons:open scheduler`,
And add `rake crawl`.
