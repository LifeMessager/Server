# LifeMessager API

## Users

### Create User

    POST /users

### Get User Info

    GET /users/:id
    GET /user

### Update User Info

    PATCH /users/:id

### Delete User

    DELETE /users/:id

### Login

    POST /users/login_mail

### Manage Subscribe

    PUT     /users/:id/subscription
    DELETE  /users/:id/subscription

### Cancel Delete Progress

    POST /users/:id/regain

## Diary

### Get Diary of Specified Day

    GET /diaries/:date

## Note

    POST /notes
