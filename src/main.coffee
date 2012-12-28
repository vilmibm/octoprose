express = require 'express'
_ = require 'underscore'

# express

app = express.createServer()
configures = [
    express.logger()
    express.favicon()
    express.cookieParser()
    express.bodyParser()
    express.session secret:'wastrel trumpet', store: new RedisStore}
    (q,s,n) ->
        s.setHeader('Access-Control-Allow-Origin', '*')
        s.setHeader('Access-Control-Allow-Credentials', 'true')
        n()
    express.static "#{__dirname}/frontend"
]
app.configure -> (app.use f for f in configures)

app.post '/login', (req, res, next) ->
    # todo

app.post '/register', (req, res, next) ->
    # todo

app.get '/logout', (req, res, next) ->
    # todo



