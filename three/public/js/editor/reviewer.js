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






