var jam = {
    "packages": [
        {
            "name": "backbone",
            "location": "jam/backbone",
            "main": "backbone.js"
        },
        {
            "name": "backbone-rel",
            "location": "jam/backbone-rel",
            "main": "backbone-relational.js"
        },
        {
            "name": "md5",
            "location": "jam/md5",
            "main": "md5.js"
        },
        {
            "name": "underscore",
            "location": "jam/underscore",
            "main": "underscore.js"
        },
        {
            "name": "cookie",
            "location": "jam/cookie",
            "main": "cookie.js"
        },
        {
            "name": "hogan",
            "location": "jam/hogan",
            "main": "hogan.js"
        },
        {
            "name": "jquery",
            "location": "jam/jquery",
            "main": "dist/jquery.js"
        }
    ],
    "version": "0.2.13",
    "shim": {
        "backbone": {
            "deps": [
                "jquery",
                "underscore"
            ],
            "exports": "Backbone"
        },
        "backbone-rel": {
            "deps": [
                "backbone"
            ]
        },
        "underscore": {
            "exports": "_"
        },
        "hogan": {
            "exports": "hogan"
        }
    }
};

if (typeof require !== "undefined" && require.config) {
    require.config({
    "packages": [
        {
            "name": "backbone",
            "location": "jam/backbone",
            "main": "backbone.js"
        },
        {
            "name": "backbone-rel",
            "location": "jam/backbone-rel",
            "main": "backbone-relational.js"
        },
        {
            "name": "md5",
            "location": "jam/md5",
            "main": "md5.js"
        },
        {
            "name": "underscore",
            "location": "jam/underscore",
            "main": "underscore.js"
        },
        {
            "name": "cookie",
            "location": "jam/cookie",
            "main": "cookie.js"
        },
        {
            "name": "hogan",
            "location": "jam/hogan",
            "main": "hogan.js"
        },
        {
            "name": "jquery",
            "location": "jam/jquery",
            "main": "dist/jquery.js"
        }
    ],
    "shim": {
        "backbone": {
            "deps": [
                "jquery",
                "underscore"
            ],
            "exports": "Backbone"
        },
        "backbone-rel": {
            "deps": [
                "backbone"
            ]
        },
        "underscore": {
            "exports": "_"
        },
        "hogan": {
            "exports": "hogan"
        }
    }
});
}
else {
    var require = {
    "packages": [
        {
            "name": "backbone",
            "location": "jam/backbone",
            "main": "backbone.js"
        },
        {
            "name": "backbone-rel",
            "location": "jam/backbone-rel",
            "main": "backbone-relational.js"
        },
        {
            "name": "md5",
            "location": "jam/md5",
            "main": "md5.js"
        },
        {
            "name": "underscore",
            "location": "jam/underscore",
            "main": "underscore.js"
        },
        {
            "name": "cookie",
            "location": "jam/cookie",
            "main": "cookie.js"
        },
        {
            "name": "hogan",
            "location": "jam/hogan",
            "main": "hogan.js"
        },
        {
            "name": "jquery",
            "location": "jam/jquery",
            "main": "dist/jquery.js"
        }
    ],
    "shim": {
        "backbone": {
            "deps": [
                "jquery",
                "underscore"
            ],
            "exports": "Backbone"
        },
        "backbone-rel": {
            "deps": [
                "backbone"
            ]
        },
        "underscore": {
            "exports": "_"
        },
        "hogan": {
            "exports": "hogan"
        }
    }
};
}

if (typeof exports !== "undefined" && typeof module !== "undefined") {
    module.exports = jam;
}