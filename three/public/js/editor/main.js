 ensure('$',
        'Reviewer',
        'Editor',
        'Piece');

var rawPiece = $('#text').text();


var piece = new Piece(      rawPiece);
var reviewer = new Reviewer(document.getElementById('reviewerContainer'), piece);
var editor   = new Editor(  document.getElementById('editorContainer'), piece);

var resizeEqual = function() {
    reviewer.resize(.5);
    editor.resize(.5);
};
var resizeUnequal = function() {
    reviewer.resize(.9);
    editor.resize(.1);
};

editor.on('show', resizeEqual);
editor.on('hide', resizeUnequal);


window.addEventListener('resize', function() {
    if (editor.hidden) {
        resizeUnequal();
    }
    else {
        resizeEqual();
    }

});

window.addEventListener('unload', piece.suggestions.save.bind(piece.suggestions));

// Actually run things:
resizeUnequal();
reviewer.render();
piece.suggestions.fetch();
