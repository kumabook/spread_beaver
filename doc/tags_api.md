Some api of this page are compatible with [Feedly Tags API](https://developer.feedly.com/v3/tags/)

## Get the list of tags created by the user.

- `GET    /v3/tags(.:format)`

## Tag an existing entry

- `PUT /v3/tags/:tagId1,:tagId2`

```
{
  "entryId": "gRtwnDeqCDpZ42bXE9Sp7dNhm4R6NsipqFVbXn2XpDA=_13fb9d6f274:2ac9c5:f5718180"
}
```

## Tag multiple entries

- `PUT /v3/tags/:tagId1,:tagId2`

```
{
  "entryIds": [
    "gRtwnDeqCDpZ42bXE9Sp7dNhm4R6NsipqFVbXn2XpDA=_13fb9d6f274:2ac9c5:f5718180",
    "9bVktswTBLT3zSr0Oy09Gz8mJYLymYp71eEVeQryp2U=_13fb9d1263d:2a8ef5:db3da1a7"
  ]
}
```

## Change a tag

- `POST   /v3/tags/:id(.:format)`

```
{
  "label": "new label"
}
```

## Untag multiple entries

- `DELETE /v3/tags/:tagId1,tagId2/:entryId1,entryId2`

## Delete a tag

- `DELETE /v3/tags/:tagId1,:tagId2`
