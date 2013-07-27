var m2h = markdown.toHTML;

var $root = $("#textContainer");

var mkspan = function(c, ix) {
    return '<span data-idx="'+ix+'">'+c+'</span>';
}

var rawText = $("#text").text();
var mdHTML = m2h(rawText);

//var $mdContainer = $("<div />").html(mdHTML);

var INEL  = 1;
var INTXT = 2;
var INENT = 3; 
var c     = 0;
var state, ch;

var newMdHTML = '';


for (var ix = 0; ix < mdHTML.length; ix++) {
    // TODO entities
    ch = mdHTML[ix];
    if (ch == '<') {
        state = INEL;
        newMdHTML += ch;
        continue;
    }
    if (ch == '>' && state == INEL) {
        state = INTXT;
        newMdHTML += ch;
        continue;
    }
    if (ch == '&' && state == INTXT) {
        state = INENT;
        newMdHTML += '<span data-idx="' + c++ + '">';
        newMdHTML += ch
        continue;
    }
    if (ch == ';' && state == INENT) {
        newMdHTML += ch;
        newMdHTML += '</span>';
        state = INTXT;
        continue;
    }
    if (state == INEL) {
        console.log(ch);
        newMdHTML += ch;
    }
    if (state == INENT) {
        console.log(ch);
        newMdHTML += ch;
    }
    if (state == INTXT) {
        newMdHTML += mkspan(ch, c++);
    }
}

$root.text(newMdHTML);






