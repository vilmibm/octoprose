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

var inherits = function(to, from) {
    var methods = slice(arguments, 2);
    for (var x = 0; x < methods.length; x++) {
        to.prototype[methods[x]] = from.prototype[methods[x]];
    }
    return to;
};

var resizeHeight = function(el, ratio) {
    // Given a DOM element and a ratio, resize the height of the
    // element using that ratio of the window height.
    ratio = ratio || .5;
    var elementHeight = window.innerHeight * ratio;
    log("Setting", el, "height to", elementHeight);
    el.style.height = String(editorHeight) + "px";
};
