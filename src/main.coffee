#/usr/bin/env coffee
async = require 'async'
express = require 'express'
hash = require 'node_hash'
p = require 'passport'
uuid = require 'node-uuid'
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
app.get '/', (req, res, next) -> res.rend 'index.html'

# data api

app.get '/currentUserTexts', ensureAuth, (q, s, n) ->
    Text.find(_user:q.user).populate('revisions').exec (err, docs) ->
        return n new DBError err if err
        s.send docs

app.get '/text/:uuid', (q, s, n) ->
    uuid = q.params.uuid
    text = Text.findOne(uuid:uuid).populate('revisions').exec (err, doc) ->
        return n new DBError err if err
        return n new NotFoundError uuid unless doc
        s.send doc

app.post '/text', ensureAuth, (q,s,n) ->
    author = q.user

    text = new Text
    text._user = author
    text.category = q.body.category
    text.desc = q.body.desc
    text.uuid = uuid.v4()

    revision = new Revision
    revision.content = q.body.revisions[0].content
    revision._text = text

    async.series [
        (cb) -> revision.save(cb),
        (cb) ->
            text.revisions.push(revision)
            text.save(cb)
    ], (e, _) -> s.send({uuid:text.uuid})

app.put '/text', ensureAuth, (q,s,n) ->
    textUuid = q.body.uuid
    newRevisionData = _(q.body.revisions).chain().sortBy('idx').last().value()
    user = q.user

    res.send 400

    #Text.findById(textUuid).populate('_user').populate('revisions').run (e, text) ->
    #    return n new DBError(e) if e
    #    return n new NotFoundError(textUuid) unless text
    #    if String(text._user._id) isnt String(user._id)
    #        return n new PermError(user._id, textUuid)

    #Text.findById(text_id).populate('_user').populate('revisions').run((e, text) ->
    #    return next new DBError(e) if e
    #    return next new NotFoundError(text_id) unless text
    #    if String(text._user._id) isnt String(user._id)
    #        return next new PermError(user._id, text_id)

    #    last_revision = _.last(_.sortBy(text.revisions, 'idx'))

    #    revision = new Revision
    #    revision.idx =  last_revision.idx + 1
    #    revision.content = new_text
    #    revision._text = text

    #    revision.save((e) ->
    #        return next new DBError(e) if e
    #        text.revisions.push(revision)
    #        text.save((e) ->
    #            return next new DBError(e) if e
    #            res.send(
    #                slug:text.slug
    #                revision_idx:revision.idx
    #            )
    #        )
    #    )
    #)

# auth
app.post '/login', p.authenticate('local', {}), (q,s,n) ->
    s.send q.user

app.post '/signup', (req, res, next) ->
    fields = ['username', 'email', 'password']

    captcha = req.body.captcha
    unless captcha and captcha.toLowerCase() in ['4', 'four']
        return next new ValidationError(captcha, 'the correct answer')

    required = ['username', 'email', 'password']
    missing = _.difference(required, _(req.body).keys())
    if missing.length > 0
        return next new ValidationError(required, _.difference(required, missing))

    user = new User
    # TODO handle unique errors
    _(user).extend _(req.body).pick(fields)

    user.save (e) ->
        return next new DBError(e) if e
        req.login user, (err) ->
            return next(err) if err
            res.send user.toJSON()
        #res.send user.toJSON()

app.get '/logout', (req, res, next) ->
    req.logout()
    res.send(200)

app.listen 3100, domain
console.log 'listening'
