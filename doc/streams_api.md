Some api of this page are compatible with [Feedly Streams API](https://developer.feedly.com/v3/streams/)

## Get a list of entry ids for a specific stream

- `GET    /v3/streams/:id/ids(.:format)`

## Get the contents of entries in a specific stream

- `GET    /v3/streams/:id/contents(.:format)`
- Currenly, only for Feed, and these global tag resources:
   - `tag/global.popular` ... popular entries in a specific period
   - `tag/global.latest`  ... latest added entries

## Get the contents of tracks in a specific stream

- `GET    /v3/streams/:id/tracks/contents(.:format)`
- Currently, only for global playlist resources
   - `playlist/global.popular` ... popular tracks in a specific period
   - `playlist/global.latest`  ... latest added tracks
