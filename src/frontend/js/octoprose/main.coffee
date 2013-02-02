define ['jquery', 'underscore', 'backbone', 'cookie', 'backbone-rel', 'js/bootstrap/bootstrap.js'], ($, _, Backbone, cookie) ->
    log = console.log
    error = console.error
    authed = -> cookie.get 'octoauth'
    Router = Backbone.Router.extend
        initialize: ->
            @route /^\/?$/, 'default', @default
        routes:
            submit: 'submit'
            peruse: 'peruse'
            account: 'account'

            'account/documents': 'account_documents',
            'account/suggestions': 'account_suggestions',
            'account/profile': 'account_profile',
            'account/logout': 'account_logout',
        default: ->
            if authed()
                return @navigate('account', trigger: true)
            @authView = new AuthView(el:$('#auth').clone())
            @recentView = new RecentView(el:$('#recent').clone())

            $('#rightbar')
                .empty()
                .show()
                .append(@recentView.$el)

            $('#center')
                .empty()
                .show()
                .append($('#frontblurb').clone().show())

            $('#leftbar')
                .empty()
                .show()
                .append(@authView.$el)
            @recentView.render()

            @authView.render()
            # this should be automatic. fucker.
            @authView.delegateEvents(@authView.events)
            @authView.on 'login', =>
                cookie.set 'octoauth', 'true'
                @navigate 'submit', trigger:true
            @authView.on 'signup', =>
                cookie.set 'octoauth', 'true'
                @navigate 'account', trigger:true
        submit: ->
            if not authed()
                return @navigate('/', trigger:true)
            $('#leftbar, #center, #rightbar').empty()
            $('#leftbar').hide()

            @editorView = new EditorView(el:$('#editor').clone())
            $('#center').append @editorView.$el
            @editorView.render()
            @editorView.delegateEvents @editorView.events
            $('#rightbar').text('SETTINGS')
        peruse: ->
            if not authed()
                return @navigate('/', trigger:true)
        account: ->
            if not authed()
                return @navigate('/', trigger:true)
            $('#center, #rightbar, #leftbar').empty()
            $('#leftbar').append($('#accountBar').clone().show()).show()
        account_documents: ->
        account_suggestions: ->
        account_profile: ->
        account_logout: ->
            cookie.remove 'octoauth'
            $.get('/logout').success(=>
                @navigate '/', trigger:true
            ).error(=> console.error 'could not logout')

    f2o = (f) ->
        data = {}
        $(f).find('*[name]').each ->
            data[@name] = $(@).val()
        data

    EditorView = Backbone.View.extend
        events:
            'submit form': 'save'
        save: (e) ->
            e.preventDefault()
            doc = f2o @$('form')
            console.log doc
            console.log 'save'
        render: -> @.$el.show()

    RecentView = Backbone.View.extend
        render: -> @$el.show()

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
        render: -> @.$el.show()

    # Models
    User = Backbone.RelationalModel.extend
        defaults:
            info: ''

    Revision = Backbone.RelationalModel.extend
        # TODO ranges
        relations: [{
            type: 'HasOne'
            key: 'text'
            relatedModel: 'Text'
            reverseRelation: {
                key: 'revisions'
            }
        }]
        defaults:
            idx: 1
            content: ''

    Text = Backbone.RelationalModel.extend
        relations: [{
            type:'HasOne'
            key:'user'
            relatedModel: 'User'
            reverseRelation: {
                key: 'text'
            }
        }],
        defaults:
            category_slug: 'no-category'
            category: 'no category'

        validate: (attrs) ->
            if not attrs.slug
                return "slug required"
            else if not desc
                return "desc required"
            else
                return

    TextCollection = Backbone.Collection.extend
        model: Text
        url: '/texts'

    #$.getJSON('/currentUserTexts').success(=>
    #).error(=>
    #)

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
