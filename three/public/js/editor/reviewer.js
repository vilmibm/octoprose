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
var Suggestions = function() {
    this._suggestions = [];
    this._callbacks = {
        push:  []
    };
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

    suggestions.push({text:  suggestionText,
                      range: [anchorIdx, focusIdx]});
};

$root.on('mouseup', mouseUpHandler);

var newSuggestionHandler = function(suggestion) {
    var rangeTuple = suggestion.range;

    console.log("New range:", rangeTuple);

    var LIDX = Math.min.apply(Math, rangeTuple);
    var RIDX = Math.max.apply(Math, rangeTuple);

    for (var idx = LIDX; idx <= RIDX; idx++) {
        root.querySelector('span[data-idx="'+idx+'"]').style.backgroundColor = 'red';
    }
};

suggestions.on('push', newSuggestionHandler);

//window.onbeforeunload = suggestions.save.bind(suggestions);
window.onunload = suggestions.save.bind(suggestions);

// Suggestion restore

suggestions.fetch();
