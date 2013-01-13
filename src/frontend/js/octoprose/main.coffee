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
            @authView = new AuthView(el:$('#auth'))
            # eventually:
            #$('#leftbar','#center','#rightbar').empty()
            $('#leftbar')
                .empty()
                .show()
                .append(@authView.$el)
            @authView.render()
            # this should be automatic. fucker.
            @authView.delegateEvents(@authView.events)
            @authView.on 'login', =>
                @navigate 'submit', trigger:true
            @authView.on 'signup', =>
                @navigate 'account', trigger:true
        submit: ->
            $('#leftbar, #center, #rightbar').empty()
            $('#leftbar').hide()

            @editorView = new EditorView(el:$('#editor'))
            $('#center').append @editorView.$el
            @editorView.render()
            @editorView.delegateEvents @editorView.events
            $('#rightbar').text('SETTINGS')
        peruse: ->
        account: ->
            console.log 'account'
        logout: ->

    f2o = (f) ->
        data = {}
        $(f).find('input').each ->
            data[@name] = $(@).val()
        data

    EditorView = Backbone.View.extend
        events:
            'submit form': 'save'
        save: (e) ->
            e.preventDefault()
            console.log 'save'
        render: ->
            @.$el.show()
            @

    AuthView = Backbone.View.extend
        events:
            'submit #login': 'login',
            'submit #signup': 'signup',
        login: (e) ->
            e.preventDefault()
            data = f2o e.target
            $.post('/login', data)
            .success(=> @trigger 'login')
            .error(=>
                console.log('nope')
                # TODO
            )
        signup: (e) ->
            e.preventDefault()
            data = f2o e.target
            $.post('/signup', data)
            .success(=> @trigger 'signup')
            .error(=>
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
