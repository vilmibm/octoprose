// preamble
var m2h = markdown.toHTML;

var $root = $("#textContainer");

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

$root.html(newMdHTML);

// selecting
var Ranges = function() {
    this._ranges = [];
    this._callbacks = {
        push: []
    };
};

Ranges.prototype.on = function(e, callback) {
    this._callbacks[e].push(callback);
    return this;
}

Ranges.prototype.emit = function(e, data) {
    for (var i = 0; i < this._callbacks[e].length; i++) {
        this._callbacks[e][i].call(this, data);
    }
    return this;
};

Ranges.prototype.push = function(rangeTuple) {
    this._ranges.push(rangeTuple);
    this.emit('push', rangeTuple);
    return this;
};

var ranges = new Ranges;
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

    ranges.push([anchorIdx, focusIdx]);

    sel.collapseToStart(); // clear selection
};

$root.on('mouseup', mouseUpHandler);

var newRangeHandler = function(rangeTuple) {
    console.log("New range:", rangeTuple);
    var LIDX = Math.min.apply(Math, rangeTuple);
    var RIDX = Math.max.apply(Math, rangeTuple);

    for (var idx = LIDX; idx <= RIDX; idx++) {
        console.log(idx);
        $('span[data-idx="'+idx+'"]').css('backgroundColor', 'red');
        // ask for new comment
        // if comment is made, add to comments collection
    }
};

ranges.on('push', newRangeHandler);
