#/usr/bin/env coffee
express = require 'express'
p = require 'passport'
_ = require 'underscore'

{}

LocalStrategy = require('passport-local').Strategy
RedisStore = require('connect-redis')(express)

p.serializeUser (user, done) -> # TODO
p.deserializeUser (email, done) -> # TODO
p.use new LocalStrategy (un, pw, done) -> # TODO
ensureAuth = (q,s,n) ->
    if q.isAuthenticated() then n() else n 403

app = express.createServer()
configures = [
    express.logger()
    express.favicon()
    express.cookieParser()
    express.bodyParser()
    express.session secret:'wastrel trumpet', store: new RedisStore
    p.initialize()
    p.session()
    express.static "#{__dirname}/frontend"
]
app.configure -> (app.use f for f in configures)

app.post '/login', p.authenticate('local', {}), (q,s,n) -> res.send 200

app.post '/register', (req, res, next) ->
    # todo

app.get '/logout', ensureAuth, (req, res, next) ->
    req.logout()
    res.send(200)

app.listen 6000, 'new.octoprose.com'
