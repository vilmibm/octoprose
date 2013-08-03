ensure(EventEmitter, Suggestions, markdown);

var Text;
scope(function() {
    Text = inherits(function(text, suggestions) {
        this.text = text || "";
        this.suggestions = suggestions || new Suggestions;
    }, EventEmitter, 'on', 'emit');
    
    Text.prototype.setText = function(newText) {
        this.text = newText;
        this.emit('update', this);
        return this;
    };
    
    Text.prototype.getRawText = function() {
        return this.text;
    };

    Text.prototype.getMarkdownText = function() {
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


