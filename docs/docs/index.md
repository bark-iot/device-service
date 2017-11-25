# Devices Service

For full Bark documentation visit [http://localhost/docs](http://localhost/docs).

## Authorization

To perform any requests you need to send user token via `Authorization` header. Example:
`Authorization: Bearer <token>`.

## Create Device

POST `/houses/:house_id/devices`

*PATH parameters*

Name         | Validation
------------ | ------------- 
house_id     | required


*POST parameters*

Name          | Validation
------------  | -------------
com_type      | optional 
title         | required

*Response [200]*

```json
{
  "id": 1,
  "house_id": 1,
  "title": "MyDevice",
  "com_type": 0,
  "token": "2d931510-d99f-494a-8c67-87feb05e1594",
  "online":false,
  "approved_at": "2017-11-11 11:04:44 UTC",
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

## Update Device

PUT `/houses/:id`

*PATH parameters*

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