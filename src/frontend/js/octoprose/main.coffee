define ['jquery', 'underscore', 'backbone', 'js/bootstrap/bootstrap.js'], ($, _, Backbone) ->
    log = console.log
    error = console.error
    Router = Backbone.Router.extend
        initialize: ->
            @route /^\/?$/, 'default', @default
        routes:
            submit: 'submit'
            peruse: 'peruse'
            account: 'account'
            logout: 'logout'
        default: ->
            console.log 'hello'
            authView = new AuthView(el:$('#auth'))
            $('#leftbar').empty().append(authView.$el)
            authView.render()
            # this should be automatic. fucker.
            authView.delegateEvents(authView.events)
        submit: ->
        peruse: ->
        account: ->
        logout: ->

    f2o = (f) ->
        data = {}
        $(f).find('input').each ->
            data[@name] = $(@).val()
        data

    AuthView = Backbone.View.extend
        events:
            'submit #login': 'login',
            'submit #signup': 'signup',
        login: (e) ->
            e.preventDefault()
            data = f2o e.target
            $.post('/login', data)
            .success(->
                console.log('yup')
                # TODO
            )
            .error(->
                console.log('nope')
                # TODO
            )
        signup: (e) ->
            e.preventDefault()
            data = f2o e.target
            $.post('/signup', data)
            .success(->
                console.log('yup')
                # TODO
            )
            .error(->
                console.log('nope')
                # TODO
            )
        render: ->
            @.$el.show()
            @

    return {
        init: ->
            router = new Router
            Backbone.history.start(pushState:false)
    }


## Perusal-related views
#
#RecentUploadsView = Backbone.View.extend
#    initialize: () ->
#
#HighActivityView = Backbone.View.extend
#    initialize: () ->
#
#FollowersUploadsView = Backbone.View.extend
#    # ul of followers uploads if any
#    initialize: () ->
#
## Submission views
#
#EditorView = Backbone.View.extend
#    # textarea
#    initialize: () ->
#
#SettingsView = Backbone.View.extend
#    # public, genre, etc
#    initialize: () ->
#
## Account views
#
#ProfileView = Backbone.View.extend
#    # form for setting un/etc
#    initialize: () ->
#
#StatsView = Backbone.View.extend
#    # comments given/accepted/etc
#    initialize: () ->
#
#ControlsView = Backbone.View.extend
#    # logout / etc
#    initialize: () ->
