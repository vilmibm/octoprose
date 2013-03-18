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
    newlineToBr = (s) -> if s then s.replace(/\n/g, '<br/>') else s

    tmpl = (name) -> hogan.compile $("##{name}").text()

    Router = Backbone.Router.extend
        initialize: ->
            @route /^\/?$/, 'default', @default
            @views = {}
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
            @views.auth = new AuthView(template:tmpl('auth'))
            @views.recent = new RecentView(template:tmpl('recent'))

            $('#rightbar')
                .empty()
                .show()
                .append(@views.recent.$el)

            $('#center')
                .empty()
                .show()
                .append($('#frontblurb').clone().show())

            $('#leftbar')
                .empty()
                .show()
                .append(@views.auth.$el)
            @views.recent.render()

            @views.auth.render()
            # this should be automatic. fucker.
            @views.auth.delegateEvents(@views.auth.events)
            @views.auth.on 'login', (userData) =>
                setCurrentUser userData
                cookie.set 'octoauth', 'true'
                @navigate 'submit', trigger:true
            @views.auth.on 'signup', =>
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

            unless @views.editorPanel
                @views.editorPanel = new EditorPanelView(template:tmpl('editorPanel'))
                @views.editorPanel.render()

            editorPanel = @views.editorPanel

            unless @views.metaControls
                @views.metaControls = new MetaControlsView(template:tmpl('metaControls'),model:text)
                @views.metaControls.render()
                editorPanel.append @views.metaControls
            else
                editorPanel.model = text

            unless @views.editor
                @views.editor = new EditorView(template:tmpl('editor'), model:text)
                @views.editor.delegateEvents @views.editor.events
                @views.editor.on 'new', (slug) => @navigate "peruse/text/#{slug}", trigger:true
                @views.editor.render()
            else
                @views.editor.model = text

            # TODO i wonder if rightbar should be affixed? as long as
            # it is being done manually?  maybe better to just keep it
            # totally manual
            editorPanel.$el.affix()

            $('#center').append(@views.editor.$el).show()
            $('#rightbar').append(editorPanel.$el).show()
        peruse: ->
            if not authed()
                return @navigate '/', trigger:true
        peruse_text: (slug) ->
            text = new Text
            text.set('slug', slug)
            $('#center, #rightbar, #leftbar').empty().hide()
            @views.text = new TextView(model:text, template: tmpl('text'))
            @views.text.delegateEvents @views.text.events
            $('#center').append(@views.text.$el).show()
            text.on 'change', => @views.text.render().show()
            text.fetch()
        account: ->
            if not authed()
                return @navigate('/', trigger:true)
            $('#center, #rightbar, #leftbar').empty().hide()
            $('#leftbar').html($('#accountBar').text()).show()

        account_documents: ->
            $('#center, #rightbar, #leftbar').empty().hide()
            $('#leftbar').html($('#accountBar').text()).show()
            unless @views.userTexts
                userTexts = new (Texts.extend url: '/currentUserTexts')
                @views.userTexts = new TextsView collection:userTexts, template: tmpl('texts')
            @views.userTexts.render().hide()
            @views.userTexts.collection.fetch(success:=>@views.userTexts.$el.show())
            $('#center').append(@views.userTexts.$el).show()

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
            'click .hide': 'hide'
            'click .show': 'show'
        hide: -> # TODO
        show: -> # TODO
        append: (view) -> @$('div.editorPanel').append(view.$el)
        render: ->
            html = @template.render()
            @$el.html html

    SuggestionNavView = Backbone.View.extend
        initialize: ({@template}) ->
        events: {}
        render: ->
            html = @template.render()
            @$el.html html

    MetaControlsView = Backbone.View.extend
        initialize: ({@template}) ->
            @model.on 'change:locked', @render.bind(@)
        events:
            'input input[name=title]': 'changeTitle'
            'input textarea[name=description]': 'changeDescription'
            'click textarea[name=description]': 'clearDescriptionPlaceholder'
            'click button.lock': 'lock'
            'click button.unlock': 'unlock'
        unlock: -> console.log('unlocking'); @model.set 'locked', false
        lock: -> console.log('unlocking');@model.set 'locked', true
        changeTitle: (e) -> @model.set('title', @$(e.target).val())
        changeDescription: (e) -> @model.set('desc', @$(e.target).text())
        clearDescriptionPlaceholder: (e) ->
            $ta = @$(e.target)
            return unless $ta.hasClass 'muted'
            $ta.text('').removeClass('muted')
        render: ->
            context =
                text: @model.toJSON()
            html = @template.render context
            @$el.html html

    EditorView = Backbone.View.extend
        initialize: ({@template}) ->
            @model.on('change:locked', @render.bind(@))
        events:
            'input p.editor': 'editMade'
            'click p.editor': 'selectPlaceholder'
        editMade: (e) ->
            newText = newlineToBr @$(e.target).text()
            @model.updateContent(newText)
        selectPlaceholder: ->
            document.execCommand('selectAll') unless @model.getContent()
        render: ->
            textObject = @model.toJSON()
            textObject.content = @model.getContent()
            context =
                text: textObject
            html = @template.render context
            @$el.html html
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
        getContent: ->
            currentRevision = @get('currentRevision') or 1
            revisions = @get('revisions')
            return undefined if revisions.length is 0
            revisions.filter((r) -> r.get('idx') is currentRevision).pop().get 'content'
        updateContent: (newText) ->
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
