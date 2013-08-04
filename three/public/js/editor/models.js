ensure('EventEmitter',
       'Suggestions',
       'markdown');

var Piece;
scope(function() {
    Piece = inherits(function(text, suggestions) {
        this.text = text || "";
        this.suggestions = suggestions || new Suggestions;
    }, EventEmitter, 'on', 'emit');

    Piece.prototype.setPiece = function(newPiece) {
        this.text = newPiece;
        this.emit('update', this);
        return this;
    };
    
    Piece.prototype.getRawText = function() {
        return this.text;
    };

    Piece.prototype.getMarkdownText = function() {
        return markdown.toHTML(this.text);
    };
});

var Suggestion;
scope(function() {
    Suggestion = function(data) {
        this.text     = data.text;
        this.range    = data.range.sort(function(a, b) { return a - b });
        this.selected = data.selected;
        this.comments = data.comments || [];
    };
});


