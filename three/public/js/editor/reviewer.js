var m2h = markdown.toHTML;

var $root = $("#textContainer");

var mkspan = function(c, ix) {
    return '<span data-idx="'+ix+'">'+c+'</span>';
}

var rawText = $("#text").text();
var mdHtml = m2h(rawText);

//var $mdContainer = $("<div />").html(mdHtml);

var INEL  = 1;
var INTXT = 2;
var INENT = 3; 
var c     = 0;
var state, ch;

var newMdHtml = '';


for (var ix = 0; ix < mdHtml.length; ix++) {
    // TODO entities
    ch = mdHtml[ix];
    if (ch == '<') {
        console.log("START EL");
        state = INEL;
        newMdHtml += ch;
        continue;
    }
    if (ch == '>' && state == INEL) {
        console.log("END EL");
        state = INTXT;
        newMdHtml += ch;
        continue;
    }
    if (state == INEL) {
        console.log(ch);
        newMdHtml += ch;
    }
    if (state == INTXT) {
        newMdHtml += mkspan(ch, c++);
    }
}

$root.text(newMdHtml);






