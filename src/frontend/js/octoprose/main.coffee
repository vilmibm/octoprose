do ->
    log = console.log
    error = console.error
    Router = Backbone.Router.extend
        routes:
            submit: "submit"
            peruse: "peruse"
            account: "account"
            login: "login"
            logout: "logout"
            register: "register"
        submit: ->
        peruse: ->
        account: ->
        login: ->
            un = $('#login input[name=name]').val()
            pw = $('#login input[name=pass]').val()

            $.post({un:un, pw:pw}, '/login')
                .success(->
                    log 'logged in'
                    window.localStorage.setItem 'auth',
                        JSON.stringify username: un
                ).error ->
                    error 'TODO no login'
        logout: () ->
            window.localStorage.removeItem 'auth'
            $.get '/logout'
            @.navigate '/', trigger:true
        register: () ->
            un = $('#register input[name=name]').val()
            pw = $('#register input[name=pass]').val()

            $.post({un:un, pw:pw}, '/register')
                .success(->
                    log 'logged in'
                    window.localStorage.setItem 'auth',
                        JSON.stringify username: un
                ).error ->
                    error 'TODO no login'

    # Perusal-related views

    RecentUploadsView = Backbone.View.extend
        initialize: () ->

    HighActivityView = Backbone.View.extend
        initialize: () ->

    FollowersUploadsView = Backbone.View.extend
        # ul of followers uploads if any
        initialize: () ->

    # Submission views

    EditorView = Backbone.View.extend
        # textarea
        initialize: () ->

    SettingsView = Backbone.View.extend
        # public, genre, etc
        initialize: () ->

    # Account views

    ProfileView = Backbone.View.extend
        # form for setting un/etc
        initialize: () ->

    StatsView = Backbone.View.extend
        # comments given/accepted/etc
        initialize: () ->

    ControlsView = Backbone.View.extend
        # logout / etc
        initialize: () ->

    Backbone.history.start(push:false)
    window._router = new Router
