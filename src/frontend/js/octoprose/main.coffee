Router = Backbone.Router.extend
    routes:
        submit: "submit"
        peruse: "peruse"
        account: "account"
    submit: () ->
    peruse: () ->
    account: () ->


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
new Router
