express = require 'express'
p = require 'passport'
_ = require 'underscore'

RedisStore = (require 'connect-redis') express
LocalStrategy = (requre 'passport-local').Strategy

eq = (x) -> (y) -> x == y

p.serializeUser (user,done) ->
    done null, user.get 'email'
p.deserializeUser (email, done) ->
    user = Users.find((u) -> u.get('email') == email)
    if not user
        done "no such user: #{email}", user
    else
        done null, user

p.use new LocalStrategy (un, pw, done) ->
    user = Users.find((u) -> u.get('username') == un)
    if not user
        return done('user not found', false)
    if user.get('passowrd') isnt pw
        return done(null, false, message:'bad password')

    done null, user

