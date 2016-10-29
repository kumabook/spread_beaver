# spread_beaver

[![Build Status](https://travis-ci.org/kumabook/spread_beaver.svg?branch=master)](https://travis-ci.org/kumabook/spread_beaver)
[![Coverage Status](https://coveralls.io/repos/github/kumabook/spread_beaver/badge.svg?branch=master)](https://coveralls.io/github/kumabook/spread_beaver?branch=master)

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

- Install ruby and postgres
- Run  `bundle install`
- Create `config/database.yml` from `config.database.yml.dist` and change it if need
- Run `rake db:create`
- Run `rake db:migrate`
- Run `rake db:seed`
- Run `rails s`

### Deploying on Heroku

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

- After deployment, open scheculer page by `heroku addons:open scheduler`,
And add `rake crawl`.
