var jam = {
    "packages": [
        {
            "name": "store",
            "location": "jam/store",
            "main": "store"
        },
        {
            "name": "md5",
            "location": "jam/md5",
            "main": "md5.js"
        },
        {
            "name": "hogan",
            "location": "jam/hogan",
            "main": "hogan.js"
        },
        {
            "name": "backbone",
            "location": "jam/backbone",
            "main": "backbone.js"
        },
        {
            "name": "underscore",
            "location": "jam/underscore",
            "main": "underscore.js"
        },
        {
            "name": "jquery",
            "location": "jam/jquery",
            "main": "dist/jquery.js"
        },
        {
            "name": "moment",
            "location": "jam/moment",
            "main": "moment.js"
        },
        {
            "name": "cookie",
            "location": "jam/cookie",
            "main": "cookie.js"
        },
        {
            "name": "backbone-rel",
            "location": "jam/backbone-rel",
            "main": "backbone-relational.js"
        },
        {
            "name": "marked",
            "location": "jam/marked",
            "main": "./lib/marked.js"
        }
    ],
    "version": "0.2.15",
    "shim": {
        "hogan": {
            "exports": "hogan"
        },
        "backbone": {
            "deps": [
                "jquery",
                "underscore"
            ],
            "exports": "Backbone"
        },
        "underscore": {
            "exports": "_"
        },
        "backbone-rel": {
            "deps": [
                "backbone"
            ]
        }
    }
};

if (typeof require !== "undefined" && require.config) {
    require.config({
    "packages": [
        {
            "name": "store",
            "location": "jam/store",
            "main": "store"
        },
        {
            "name": "md5",
            "location": "jam/md5",
            "main": "md5.js"
        },
        {
            "name": "hogan",
            "location": "jam/hogan",
            "main": "hogan.js"
        },
        {
            "name": "backbone",
            "location": "jam/backbone",
            "main": "backbone.js"
        },
        {
            "name": "underscore",
            "location": "jam/underscore",
            "main": "underscore.js"
        },
        {
            "name": "jquery",
            "location": "jam/jquery",
            "main": "dist/jquery.js"
        },
        {
            "name": "moment",
            "location": "jam/moment",
            "main": "moment.js"
        },
        {
            "name": "cookie",
            "location": "jam/cookie",
            "main": "cookie.js"
        },
        {
            "name": "backbone-rel",
            "location": "jam/backbone-rel",
            "main": "backbone-relational.js"
        },
        {
            "name": "marked",
            "location": "jam/marked",
            "main": "./lib/marked.js"
        }
    ],
    "shim": {
        "hogan": {
            "exports": "hogan"
        },
        "backbone": {
            "deps": [
                "jquery",
                "underscore"
            ],
            "exports": "Backbone"
        },
        "underscore": {
            "exports": "_"
        },
        "backbone-rel": {
            "deps": [
                "backbone"
            ]
        }
    }
});
}
else {
    var require = {
    "packages": [
        {
            "name": "store",
            "location": "jam/store",
            "main": "store"
        },
        {
            "name": "md5",
            "location": "jam/md5",
            "main": "md5.js"
        },
        {
            "name": "hogan",
            "location": "jam/hogan",
            "main": "hogan.js"
        },
        {
            "name": "backbone",
            "location": "jam/backbone",
            "main": "backbone.js"
        },
        {
            "name": "underscore",
            "location": "jam/underscore",
            "main": "underscore.js"
        },
        {
            "name": "jquery",
            "location": "jam/jquery",
            "main": "dist/jquery.js"
        },
        {
            "name": "moment",
            "location": "jam/moment",
            "main": "moment.js"
        },
        {
            "name": "cookie",
            "location": "jam/cookie",
            "main": "cookie.js"
        },
        {
            "name": "backbone-rel",
            "location": "jam/backbone-rel",
            "main": "backbone-relational.js"
        },
        {
            "name": "marked",
            "location": "jam/marked",
            "main": "./lib/marked.js"
        }
    ],
    "shim": {
        "hogan": {
            "exports": "hogan"
        },
        "backbone": {
            "deps": [
                "jquery",
                "underscore"
            ],
            "exports": "Backbone"
        },
        "underscore": {
            "exports": "_"
        },
        "backbone-rel": {
            "deps": [
                "backbone"
            ]
        }
    }
};
}

if (typeof exports !== "undefined" && typeof module !== "undefined") {
    module.exports = jam;
}