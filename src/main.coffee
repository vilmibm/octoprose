#/usr/bin/env coffee
async = require 'async'
express = require 'express'
hash = require 'node_hash'
p = require 'passport'
node_uuid = require 'node-uuid'
_ = require 'underscore'

domain = process.env.OCTO_DOMAIN or 'localhost'

LocalStrategy = require('passport-local').Strategy
RedisStore = require('connect-redis')(express)

# errors
{ Error, NotFoundError, PermError, DBError, ValidationError } = require './errors'

# models
models = require('./models')
{ Suggestion, Revision, Range, User, Text } = require './models'

p.serializeUser (user, done) -> done null, user.email
p.deserializeUser (email, done) ->
    User.findOne {email:email}, (e, user) ->
        if not user
            return done "no such user: #{email}", user
        if e
            return done e, user
        done null, user

p.use new LocalStrategy (em, pw, done) -> # TODO
    User.findOne({email:em}, (e,user) ->
        if e or not user
            return done(e, false, {message: "who is #{em}"})

        if user.password isnt pw
            return done(null, false, {message: "bad password for #{em}"})

        done(null, user)
    )

ensureAuth = (q,s,n) ->
    if q.isAuthenticated() then n() else n 403
app = express()
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
app.engine '.html', (str) -> str
app.set('views', "#{__dirname}/../front")

# the page
app.get '/', (q, s) -> s.rend 'index.html'

# data api

app.get '/owns/:uuid', ensureAuth, (q, s) ->
    Text.findOne(_user:q.user, uuid:q.params.uuid).exec (err, doc) ->
        return (new DBError err).finish(s) if err
        return s.send {
            isOwner: Boolean(doc)
        }

app.get '/user/:id/texts', (q, s) ->
    return s.send [] unless q.isAuthenticated()

    Text.find(_user:q.user).populate('revisions').exec (err, docs) ->
        return (new DBError err).finish(s) if err
        s.send docs

app.get '/text/:uuid', (q, s) ->
    uuid = q.params.uuid
    text = Text.findOne(uuid:uuid).populate('revisions').populate('_user').exec (err, doc) ->
        return (new DBError err).finish(s) if err
        return (new NotFoundError uuid).finish(s) unless doc
        s.send doc

app.get '/texts/recent', (q, s) ->
    Text.find().sort('-updated').limit(10).populate('_user', 'username').exec (err, docs) ->
        return (new DBError err).finish(s) if err
        s.send docs

app.post '/text', ensureAuth, (q,s) ->
    author = q.user

    textData = q.body

    text = new Text
    text._user = author
    # TODO category
    text.desc = textData.desc
    text.title = textData.title
    text.draft = textData.draft
    text.uuid = node_uuid.v4()

    revision = new Revision
    revision.content = textData.revisions[0].content
    revision._text = text

    async.series [
        (cb) -> revision.save(cb),
        (cb) ->
            text.revisions.push(revision)
            text.save(cb)
    ], (e, _) -> s.send({uuid:text.uuid})

app.put '/text', ensureAuth, (q,s) ->
    user = q.user
    textData = q.body

    Text.findOne(uuid:textData.uuid).populate('_user').populate('revisions').exec (e, text) ->
        return (new DBError e).finish(s) if e
        return (new NotFoundError(textData.uuid)).finish(s) unless text
        if String(text._user._id) isnt String(user._id)
            return (new PermError(user._id, text.uuid)).finish s

        text.uuid = textData.uuid
        text.draft = textData.draft
        text.title = textData.title
        text.desc = textData.desc
        # TODO category

        finish = (e) ->
            return (new DBError e).finish(s) if e
            s.send 200

        # sync last revision if necessary
        unless textData.revisions.length is text.revisions.length
            newRevisionData = _(textData.revisions).chain().sortBy('idx').last().value()
            newRevision = new Revision newRevisionData
            newRevision._text = text
            newRevision.save (e) ->
                return (new DBError e).finish(s) if e
                text.revisions.push newRevision
                text.save finish
        else
            text.save finish

# auth
app.post '/login', p.authenticate('local', {}), (q,s) ->
    s.send q.user

app.post '/signup', (q, s) ->
    fields = ['username', 'email', 'password']

    captcha = q.body.captcha
    unless captcha and captcha.toLowerCase() in ['4', 'four']
        return (new ValidationError captcha, 'the correct answer').finish(s)

    required = ['username', 'email', 'password']
    missing = _.difference(required, _(q.body).keys())
    if missing.length > 0
        return (new ValidatonError(required, _.difference(required, missing))).finish s

    user = new User
    # TODO handle unique errors
    _(user).extend _(q.body).pick(fields)

    user.save (e) ->
        return (new DBError e).finish(s) if e
        q.login user, (e) ->
            return (new Error e).finish(s) if e
            s.send user.toJSON()

app.get '/logout', (q, s) ->
    q.logout()
    s.send(200)

app.listen 3100, domain
console.log 'listening'
