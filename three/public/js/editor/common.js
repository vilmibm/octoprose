var DEBUG = true;

var ensure = function() {
    for (var x = 0; x < arguments.length; x++) {
        var requirement = arguments[x];
        if (!window[requirement]) {
            throw "Missing requirement:" + requirement;
        }
    }
};

var slice = function(a, x, y) {
    return Array.prototype.slice.call(a, x, y);
};

var log = function() {
    if (DEBUG) {
        return console.log.apply(console, arguments);
    }
};

var error = function() {
    if (DEBUG) {
        return console.error.apply(console, arguments);
    }
};

var scope = function(fn) {
    return fn.apply(this, slice(arguments, 1));
};

var mixin = function(to) {
    var froms = slice(arguments, 1);
    var from, methods;

    for (var x = 0; x < froms.length; x++) {
        from    = froms[x][0];
        methods = froms[x].slice(1);
        for (var y = 0; y < methods.length; y++) {
            to.prototype[methods[y]] = from.prototype[methods[y]];
        }
    }

    return to;
};
