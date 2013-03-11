reqs = [
    'jquery'
    'underscore'
    'backbone'
    'md5'
    'cookie'
    'hogan'
    'store'
    'moment'
    'backbone-rel'
    'js/bootstrap/bootstrap.js'
]
define reqs, ($, _, Backbone, md5, cookie, hogan, store, moment) ->
    slugify = (d) -> md5.hex(d + String(Date.now()))
    authed = cookie.get.bind cookie, 'octoauth'
    getCurrentUser = -> new User(store.get 'user')
    setCurrentUser = (data) ->
         store.set('user', data)
         return new User(data)
    unsetCurrentUser = -> store.remove 'user'
    tmpl = (name) -> hogan.compile $("##{name}").text()

    Router = Backbone.Router.extend
        initialize: ->
            @route /^\/?$/, 'default', @default
        routes:
            submit: 'submit'

            peruse: 'peruse'
            'peruse/text/:slug': 'peruse_text'

            account: 'account'
            'account/documents': 'account_documents',
            'account/suggestions': 'account_suggestions',
            'account/profile': 'account_profile',
            'account/logout': 'account_logout',
        default: ->
            if authed()
                return @navigate('account', trigger: true)
            @authView = new AuthView(template:tmpl('auth'))
            @recentView = new RecentView(template:tmpl('recent'))

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
            @authView.on 'login', (userData) =>
                setCurrentUser userData
                cookie.set 'octoauth', 'true'
                @navigate 'submit', trigger:true
            @authView.on 'signup', =>
                cookie.set 'octoauth', 'true'
                @navigate 'account', trigger:true
        submit: ->
            # This route is a shortcut for creating a new document and working
            # on it.
            if not authed()
                return @navigate('/', trigger:true)
            $('#leftbar, #center, #rightbar').empty()
            $('#leftbar').hide()

            # Always make a new document when clicking submit.
            text = new Text

            unless @editorPanelView
                @editorPanelView = new EditorPanelView(template:tmpl('editorPanel'),model:text)
                @editorPanelView.render()
            else
                @editorPanelView.model = text

            unless @editorView
                @editorView = new EditorView(template:tmpl('editor'), model:text)
                @editorView.delegateEvents @editorView.events
                @editorView.on 'new', (slug) => @navigate "peruse/text/#{slug}", trigger:true
                @editorView.render()
            else
                @editorPanelView.model = text

            $('#center').append(@editorView.$el).show()
            $('#rightbar').append(@editorPanelView.$el).show()
        peruse: ->
            if not authed()
                return @navigate '/', trigger:true
        peruse_text: (slug) ->
            text = new Text
            text.set('slug', slug)
            $('#center, #rightbar, #leftbar').empty().hide()
            @textView = new TextView(model:text, template: tmpl('text'))
            @textView.delegateEvents @textView.events
            $('#center').append(@textView.$el).show()
            text.on 'change', => @textView.render().show()
            text.fetch()
        account: ->
            if not authed()
                return @navigate('/', trigger:true)
            $('#center, #rightbar, #leftbar').empty().hide()
            $('#leftbar').html($('#accountBar').text()).show()

        account_documents: ->
            $('#center, #rightbar, #leftbar').empty().hide()
            $('#leftbar').html($('#accountBar').text()).show()
            unless @userTextsView
                userTexts = new (Texts.extend url: '/currentUserTexts')
                @userTextsView = new TextsView collection:userTexts, template: tmpl('texts')
            @userTextsView.render().hide()
            @userTextsView.collection.fetch(success:=>@userTextsView.$el.show())
            $('#center').append(@userTextsView.$el).show()

        account_suggestions: ->
        account_profile: ->
        account_logout: ->
            cookie.remove 'octoauth'
            unsetCurrentUser()
            $.get('/logout').success(=>
                @navigate '/', trigger:true
            ).error(=> console.error 'could not logout')

    f2o = (f) ->
        data = {}
        $(f).find('*[name]').each ->
            data[@name] = $(@).val()
        data

    TextView = Backbone.View.extend
        tagName: 'div'
        initialize: ({@template}) ->
        render: ->
            context =
                desc: @model.get('desc')
                content: @model.get('revisions').last().get('content')

            @$el.html(@template.render(context))

    TextsView = Backbone.View.extend
        initialize: ({@template}) ->
            @collection.on('reset', @render.bind @)
        events:
            'click button.refresh': 'refresh'
        refresh: -> @collection.fetch()
        render: ->
            truncate = (n, s) -> if s.length > n then "#{s[..n]}..." else s
            context =
                texts: @collection.map (text) -> {
                    desc: truncate(100, text.get('desc'))
                    numRevisions: text.get('revisions').length
                    created: moment(text.get('created')).fromNow()
                }
            html = @template.render context
            @$el.html html

    EditorPanelView = Backbone.View.extend
        initialize: ({@template}) ->
        events:
            'input input[name=title]': 'changeTitle'
            'input textarea[name=description]': 'changeDescription'
            'click textarea[name=description]': 'clearDescription'
        changeTitle: (e) ->
            @model.set('title', @$(e.target).val())
        changeDescription: (e) ->
            @model.set('desc', @$(e.target).text())
        clearDescription: (e) ->
            $ta = @$(e.target)
            return unless $ta.hasClass 'muted'
            $ta.text('')
            $ta.removeClass('muted')
        render: ->
            html = @template.render()
            @$el.html html

    EditorView = Backbone.View.extend
        initialize: ({@template}) ->
        events:
            'input p.editor': 'editMade'
        editMade: (e) ->
            newText = @$(e.target).text()
            @model.updateText(newText)
        save: (e) ->
            # TODO DEPRECATED
            e.preventDefault()
            data = f2o @$('form')
            text = new Text
            u = getCurrentUser()
            text.set('desc', data.title)
            text.set('user', u)
            text.set('slug', slugify(text.get('desc')))

            revision = new Revision
            revision.set('content', data.content)
            text.get('revisions').add revision
            text.on 'sync', => @trigger 'new', text.get('slug')
            text.save()
        render: -> @$el.html(@template.render())

    RecentView = Backbone.View.extend
        initialize: ({@template}) ->
        render: -> @$el.html(@template.render())

    AuthView = Backbone.View.extend
        initialize: ({@template}) ->
        events:
            'submit #login': 'login',
            'submit #signup': 'signup',
        login: (e) ->
            e.preventDefault()
            data = f2o e.target
            $.post('/login', data)
            .success((data) =>
                @trigger 'login', data
            )
            .error(=>
                console.log('nope')
                # TODO
            )
        signup: (e) ->
            e.preventDefault()
            data = f2o e.target
            $.post('/signup', data)
            .success((data) =>
                setCurrentUser data
                @trigger 'signup'
            )
            .error(=>
                console.log('nope')
                # TODO
            )
        render: -> @$el.html @template.render()

    # Models
    window.User = Backbone.RelationalModel.extend
        defaults:
            info: ''


    window.Text = Backbone.RelationalModel.extend
        url: '/text'
        relations: [{
            type:'HasOne'
            key:'user'
            relatedModel: 'User'
            reverseRelation: {
                key: 'texts'
            }
        }, {
            type: 'HasMany'
            key: 'revisions'
            relatedModel: 'Revision'
            reverseRelation: {
                type: 'HasOne'
                key: 'text'
            }
        }],
        updateText: (newText) ->
            revisions = @get 'revisions'
            currentRevision = @get('currentRevision') or 1
            if revisions.length is 0
                @set 'revisions', new Revision
            revisions.filter((r) -> r.get('idx') is currentRevision).pop().set 'content', newText
        sync: (method, text) ->
            if method isnt 'read'
                return Backbone.sync.apply(Backbone, arguments)

            $.getJSON("/text/#{text.get('slug')}")
                .success((data) ->
                    text.set data
                    text.trigger 'sync'
                )
                .error -> console.error text.get('slug')

        defaults:
            category: 'no category'

    window.Revision = Backbone.RelationalModel.extend
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


    # Collections
    Texts = Backbone.Collection.extend
        model: Text
        url: '/texts'

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
