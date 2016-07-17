Some api of this page are compatible with [Feedly Profile API](https://developer.feedly.com/v3/profile/)

## Create the profile of a user

- `PUT    /v3/profile(.:format)`
- This api requires Basic Authentication instead of OAuth Authentication

#### Request

- email: String
- password: String
- password_confirmation: String

#### Response

```
{
  "id": "2f8940d0-9117-4df5-8e8d-61ff7be1c6cc",
  "email": "new_user@test.com",
  "created_at": "2016-03-14T06:51:52.822+09:00",
  "updated_at": "2016-03-14T06:51:52.822+09:00"
}
```

## Get access token of a user

- `GET    /v3/profile(.:format)`
