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
    authed = cookie.get.bind cookie, 'octoauth'
    owner = (uuid, cb) ->
        $.getJSON("owns/#{uuid}")
            .success((data) ->
                cb null, data.isOwner
            )
            .error cb.bind({}, 'panic')

    newlineToBr = (s) -> if s then s.replace(/\n/g, '<br/>') else s

    tmpl = (name) -> hogan.compile $("##{name}").text()

    Router = Backbone.Router.extend
        setCurrentUser: (userData) ->
            @user = new User userData
            @collections.userTexts = new UserTexts @user
            @collections.userTexts.fetch(async:false)
            return @user
        initialize: ->
            @route /^\/?$/, 'default', @default
            @views = {}
            @collections = {}
            if cookie.get 'octoauth'
                @setCurrentUser store.get 'userData'
        routes:
            submit: 'submit'
            'edit/:uuid': 'editText'

            'text/:uuid': 'text'
            'preview/:uuid': 'preview'

            peruse: 'peruse'
            'peruse/:uuid': 'peruseText'

            account: 'account'
            'account/documents': 'account_documents',
            'account/suggestions': 'account_suggestions',
            'account/profile': 'account_profile',
            'account/logout': 'account_logout',
        default: ->
            if authed()
                return @navigate('account', trigger: true)
            vs = (@views.auth = @views.auth || {})
            vs.auth = new AuthView(template:tmpl('auth'))
            vs.recent = new RecentView(template:tmpl('recent'))

            $('#rightbar')
                .empty()
                .show()
                .append(vs.recent.$el)

            $('#center')
                .empty()
                .show()
                .append($('#frontblurb').clone().show())

            $('#leftbar')
                .empty()
                .show()
                .append(vs.auth.$el)
            vs.recent.render()

            vs.auth.render()
            # this should be automatic. fucker.
            vs.auth.delegateEvents(vs.auth.events)
            userEntry = (userData) =>
                @setCurrentUser userData
                cookie.set 'octoauth', 'true'
                store.set 'userData', userData
                @navigate 'account/documents', trigger:true
            vs.auth.on 'login', userEntry
            vs.auth.on 'signup', userEntry
        text: (uuid) ->
            nav = (r) => @navigate "#{r}/#{uuid}", trigger:true
            unless authed()
                return nav 'preview'

            owner uuid, (err, isOwner) ->
                nav( if isOwner then 'edit' else 'peruse' )
        preview: (uuid) ->
            console.log 'PREVIEWING'
        editText: (uuid) ->
            $('#leftbar, #rightbar, #center').empty()
            $('#leftbar').hide()
            vs = (@views.editText = @views.editText or {})
            text = @collections.userTexts.find (t) -> t.get('uuid') is uuid

            (vs.panel = new EditorPanelView template:tmpl('editorPanel'), model: text).render()

            (vs.meta = new MetaControlsView template: tmpl('metaControls'), model: text).render()

            vs.panel.append vs.meta

            (vs.sugNav = new SuggestionNavView template:tmpl('suggestionNav'), model: text).render()

            vs.panel.append vs.sugNav


            (vs.editor = new EditorView template:tmpl('editor'), model: text).render()

            text.fetch()

            $('#center').append(vs.editor.$el).show()
            $('#rightbar').append(vs.panel.$el).show()

        peruseText: (uuid) ->
            $('#leftbar, #rightbar, #center').empty()
            $('#leftbar').hide()
            @views.peruseText = {} unless @views.peruseText
            text = @collections.userTexts.find (t) -> t.get('uuid') is uuid
            vs = @views.peruseText

            (vs.panel = new EditorPanelView template:tmpl('editorPanel'), model: text).render()

            (vs.sugNav = new SuggestionNavView template:tmpl('suggestionNav'), model: text).render()

            vs.panel.append vs.sugNav

            (vs.editor = new EditorView template:tmpl('editor'), model: text).render()

            text.set 'lock', true
            text.fetch()

            $('#center').append(vs.editor.$el).show()
            $('#rightbar').append(vs.panel.$el).show()
        submit: ->
            # This route is a shortcut for creating a new document and working
            # on it.
            if not authed()
                return @navigate('/', trigger:true)
            $('#leftbar, #center, #rightbar').empty()
            $('#leftbar').hide()

            # Always make a new document when clicking submit.
            text = new Text

            vs = (@views.submit = @views.submit or {})

            vs.panel = new EditorPanelView template:tmpl('editorPanel')
            vs.panel.render()

            vs.meta = new MetaControlsView template: tmpl('metaControls'), model: text
            vs.meta.render()
            vs.panel.append vs.meta

            vs.editor = new EditorView template: tmpl('editor'), model: text
            
            vs.editor.delegateEvents vs.editor.events # TODO why u no work automagically
            vs.editor.render()

            $('#center').append(vs.editor.$el).show()
            $('#rightbar').append(vs.panel.$el).show()
        peruse: ->
            if not authed()
                return @navigate '/', trigger:true
        peruse_text: (uuid) ->
            text = new Text
            text.set('uuid', uuid)
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
            userTexts = @collections.userTexts
                
            vs = (@views.account_documents = @views.account_documents or {})
            vs.userTexts = new TextsView collection:userTexts, template: tmpl('texts')
            vs.userTexts.render()
            $('#center').append(vs.userTexts.$el).show()

        account_suggestions: ->
        account_profile: ->
        account_logout: ->
            cookie.remove 'octoauth'
            delete @user
            delete @collections.userTexts
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
                    uuid: text.get('uuid')
                    title: text.get('title')
                    desc: truncate(100, text.get('desc'))
                    numRevisions: text.get('revisions').length
                    created: moment(text.get('created')).fromNow()
                }
            html = @template.render context
            @$el.html html

    EditorPanelView = Backbone.View.extend
        initialize: ({@template}) ->
            @$el.affix()
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
            'focus textarea[name=description]': 'clearDescriptionPlaceholder'
            'click button.lock': 'lock'
            'click button.unlock': 'unlock'
            'click button.save': 'saveNewRevision'
        unlock: -> console.log('unlocking'); @model.set 'locked', false
        lock: -> console.log('unlocking');@model.set 'locked', true
        changeTitle: (e) -> @model.set('title', @$(e.target).val())
        changeDescription: (e) -> @model.set('desc', @$(e.target).val())
        clearDescriptionPlaceholder: (e) ->
            $ta = @$(e.target)
            return unless $ta.hasClass 'muted'
            $ta.val('').removeClass('muted')
        saveNewRevision: (e) ->
            @model.saveNewRevision()
            @model.save().success ({uuid}) => @model.set 'uuid', uuid
        render: ->
            context =
                text: @model.toJSON()
            html = @template.render context
            @$el.html html

    EditorView = Backbone.View.extend
        initialize: ({@template}) ->
            @model.on 'change:locked', @render.bind(@)
            @model.on 'sync', @render.bind(@)
        events:
            'input p.editor': 'editMade'
            'click p.editor': 'selectPlaceholder'
        editMade: (e) ->
            newText = newlineToBr @$(e.target).text()
            @model.set('draft', newText)
        selectPlaceholder: ->
            document.execCommand('selectAll') unless @model.get 'draft'
        render: ->
            textObject = @model.toJSON()
            textObject.content = @model.get 'draft'
            context =
                text: textObject
            html = @template.render context
            @$el.html html

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
            .success((userData) =>
                @trigger 'signup', userData
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
        idAttribute: 'uuid'
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
        saveNewRevision: ->
            newText = @get 'draft'
            revisions = @get 'revisions'
            if revisions.length is 0
                idx = 1
            else
                idx = 1 + (revisions.last().get 'idx')
            revision = new Revision
                content: newText
                idx: idx
            revisions.push revision
            @set 'revisions', revisions
        sync: (method, text) ->
            if method isnt 'read'
                return Backbone.sync.apply(Backbone, arguments)

            $.getJSON("/text/#{text.get('uuid')}")
                .success((data) ->
                    text.set data
                    text.trigger 'sync'
                )
                .error -> console.error text.get('uuid')

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

    UserTexts = Texts.extend
        initialize: (@user) ->
        url: -> "/user/#{@user.get('_id')}/texts"

    return {
        init: ->
            router = new Router
            Backbone.history.start(pushState:false)
    }