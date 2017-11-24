# Houses Service

For full Bark documentation visit [http://localhost/docs](http://localhost/docs).

## Authorization

To perform any requests you need to send user token via `Authorization` header. Example:
`Authorization: Bearer <token>`.

## Create House

POST `/houses`

*POST parameters*

Name         | Validation
------------ | -------------
address      | optional 
title        | required

*Response [200]*

```json
{
  "id": 1,
  "user_id": 1,
  "title": "MyHouse",
  "address": "Baker Street 221B",
  "key": "2d931510-d99f-494a-8c67-87feb05e1594",
  "secret": "cd8a74e54129e64172fe692526dfb4c9641639e95ac48e91c0d3be2c03a32e5c",
  "created_at": "2017-11-11 11:04:44 UTC",
  "updated_at": "2017-1-11 11:04:44 UTC"
}
```

*Error Response [422]*

```json
[
  ["title", ["must be filled"]]
]
```

*Error Response [401]*

Wrong user token

## Update House

PUT `/houses/:id`

*GET parameters*

Name         | Validation
------------ | ------------- 
id           | required

*PUT parameters*

Name         | Validation
------------ | -------------
address      | optional 
title        | required

*Response [200]*

```json
{
  "id": 1,
  "user_id": 1,
  "title": "MyHouse",
  "address": "Baker Street 221B",
  "key": "2d931510-d99f-494a-8c67-87feb05e1594",
  "created_at": "2017-11-11 11:04:44 UTC",
  "updated_at": "2017-1-11 11:04:44 UTC"
}
```

*Error Response [422]*

```json
[
  ["title", ["must be filled"]]
]
```

*Error Response [401]*

Wrong user token

## List Houses

GET `/houses`

*Response [200]*

```json
[
    {
      "id": 1,
      "user_id": 1,
      "title": "MyHouse",
      "address": "Baker Street 221B",
      "key": "2d931510-d99f-494a-8c67-87feb05e1594",
      "created_at": "2017-11-11 11:04:44 UTC",
      "updated_at": "2017-1-11 11:04:44 UTC"
    }
]
```

*Error Response [401]*

No token provided

## Delete House

DELETE `/houses/:id`

*GET parameters*

Name         | Validation
------------ | ------------- 
id           | required

*Response [200]*

Deleted.

*Error Response [401]*

No token provided