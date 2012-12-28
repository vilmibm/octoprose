Backbone = require 'backbone'

User = Backbone.Model.extend
    defaults:
        username: ''
        email: ''
        password: ''
        info: ''
        url: ''
        show_email: false
        flags: 0
        made: 0
        accepted: 0
        rejected: 0
