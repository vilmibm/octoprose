 ensure('$',
        'Reviewer',
        'Editor',
        'Piece');

var rawPiece = $('#text').text();

var piece = new Piece(      rawPiece);
var reviewer = new Reviewer(document.getElementById('reviewerContainer'), piece);
var editor   = new Editor(  document.getElementById('editorContainer'), piece);

piece.suggestions.fetch();
reviewer.render();

window.addEventListener('unload', piece.suggestions.save.bind(piece.suggestions));
