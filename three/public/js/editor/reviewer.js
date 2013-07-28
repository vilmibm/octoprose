// preamble
var m2h = markdown.toHTML.bind(markdown);
var $id = document.getElementById.bind(document);

var $root = $("#textContainer");
var root  = $id("textContainer");

// create selectable text
// TODO this could be done server side.
var rawText = $("#text").text();
var mdHTML = m2h(rawText);

var INEL  = 1;
var INTXT = 2;
var INENT = 3;
var idx   = 0; // span index
var state;
var ch, cix; // character, character index

var newMdHTML = '';

for (var cix = 0; cix < mdHTML.length; cix++) {
    ch = mdHTML[cix];
    if (ch == '<') {
        state = INEL;
    }
    else if (ch == '>' && state == INEL) {
        state = INTXT;
    }
    else if (ch == '&' && state == INTXT) {
        state = INENT;
        newMdHTML += '<span data-idx="' + idx++ + '">';
    }
    else if (ch == ';' && state == INENT) {
        newMdHTML += ch;
        newMdHTML += '</span>';
        state = INTXT;
        continue;
    }
    else if (state == INTXT) {
        newMdHTML += '<span data-idx="'+ idx++ +'">'+ch+'</span>';
        continue;
    }
    newMdHTML += ch;
}

root.innerHTML = newMdHTML;

// selecting
var Suggestion = function(data) {
    this.text     = data.text;
    this.range    = data.range.sort(function(a, b) { return a - b });
    this.selected = data.selected;
    this.comments = data.comments || [];
};

var Suggestions = function() {
    this._suggestions = [];
    this._callbacks = {
        push:  []
    };
};

Suggestions.prototype.findByIdx = function(idx) {
    var matches = [];
    for (var i = 0; i < this._suggestions.length; i++) {
        var suggestion = this._suggestions[i];
        var range = suggestion.range;
        if (idx >= range[0] && idx <= range[1]) {
            matches.push(suggestion);
        }
    }

    var sortedMatches = matches.sort(function(a, b) {
        return a.range[1] - a.range[0] - b.range[1] - b.range[0];
    });

    console.log("FoundByIdx:", sortedMatches);

    return sortedMatches;
};

Suggestions.prototype.fetch = function() {
    var oldSuggestions = JSON.parse(window.localStorage.getItem('suggestions'));
    if (oldSuggestions.length > 0) {
        this.reset(oldSuggestions);
    }
};

Suggestions.prototype.reset = function(suggestions) {
    this._suggestions = suggestions;
    for (var i = 0; i < this._suggestions.length; i++) {
        this._emit('push', this._suggestions[i]);
    }
    return this;
};

Suggestions.prototype.on = function(e, callback) {
    this._callbacks[e].push(callback);
    return this;
}

Suggestions.prototype._emit = function(e, data) {
    for (var i = 0; i < this._callbacks[e].length; i++) {
        this._callbacks[e][i].call(this, data);
    }
    return this;
};

Suggestions.prototype.push = function(suggestion) {
    this._suggestions.push(suggestion);
    this._emit('push', suggestion);
    return this;
};

Suggestions.prototype.save = function() {
    console.log("Saving suggestions");
    // TODO go to a backend
    window.localStorage.setItem('suggestions', JSON.stringify(this._suggestions));
    return this;
};

var suggestions = new Suggestions;
var sel = window.getSelection(); // this function returns a singleton reference.

var mouseUpHandler = function(e) {
    var selectedText = sel.toString();
    if (selectedText.length === 0) {
        console.log('Empty selection');
        return;
    }

    console.log('Selected text:', selectedText);

    var anchorIdx = Number(sel.anchorNode.parentElement.dataset['idx']);
    var focusIdx  = Number(sel.focusNode.parentElement.dataset['idx' ]);

    sel.collapseToStart(); // clear selection

    // TODO ask for suggestion with modal
    var suggestionText = "The palatable comb " + String(Math.floor(100*Math.random()));

    if (!suggestionText) {
        console.log("No suggestion. Moving on");
        return;
    }

    suggestions.push(new Suggestion({text:     suggestionText,
                                     selected: selectedText,
                                     range:    [anchorIdx, focusIdx]}));
};

$root.on('mouseup', mouseUpHandler);

var RGBA = function(r, g, b, a) {
    this.r = r || 0;
    this.g = g || 0;
    this.b = b || 0;
    this.a = a || 1;
};

RGBA.prototype.toString = function() {
    return 'rgba('+this.r+','+this.g+','+this.b+','+this.a+')';
};

RGBA.prototype.clone = function() {
    return new RGBA(this.r, this.g, this.b, this.a);
};

var baseBgColor = new RGBA(255, 0, 0, .1);

var opaquen = function(bgColor) {
    var newRGBA = bgColor.clone();
    newRGBA.a = newRGBA.a + .1;
    return newRGBA;
};

var RGBAFromString = function(string) {
    var commaSep = string
        .replace('rgba(', '')
        .replace(')', '')
        .split(',');
    var toNumber = function(str) {
        return Number(str.replace(/ /g, ''));
    };
    var r = toNumber(commaSep[0]);
    var g = toNumber(commaSep[1]);
    var b = toNumber(commaSep[2]);
    var a = toNumber(commaSep[3]);

    return new RGBA(r, g, b, a);
};

var newSuggestionHandler = function(suggestion) {
    var rangeTuple = suggestion.range;

    console.log("New range:", rangeTuple);

    var lidx = rangeTuple[0];
    var ridx = rangeTuple[1];

    var span, bgColor;

    for (var idx = lidx; idx <= ridx; idx++) {
        span = root.querySelector('span[data-idx="'+idx+'"]');
        if (span.style.backgroundColor.length === 0) {
            bgColor = baseBgColor;
        }
        else {
            bgColor = opaquen(RGBAFromString(span.style.backgroundColor));
        }

        span.style.backgroundColor = bgColor.toString();

        $(span).addClass('highlight');
    }

    return true;
};

suggestions.on('push', newSuggestionHandler);

window.onunload = suggestions.save.bind(suggestions);

// Suggestion restore
suggestions.fetch();

// Add comment to existing suggestion

var suggestionClickHandler = function(e) {
    var span = e.target;
    if ( ! $(span).hasClass('highlight') ) {
        console.log("Click not on a suggestion");
        return true;
    }

    // TODO ask for comment
    var commentText = "Science and Magic " + String(Math.floor(100*Math.random()));

    if (commentText.length === 0) {
        console.log("No comment entered, moving on");
        return;
    }

    var idx = Number(span.dataset.idx);
    var suggestion = suggestions.findByIdx(idx).pop();

    console.log("Adding comment to:", suggestion);

    suggestion.comments.push({text:commentText});

    return true;
};

$root.on('click', 'span.highlight', suggestionClickHandler);
