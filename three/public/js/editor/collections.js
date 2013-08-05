ensure('EventEmitter');

var Suggestions;
scope(function() {
    Suggestions = mixin(function() {
        this._suggestions = [];
    }, [EventEmitter, 'on', 'emit']);

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

        log("FoundByIdx:", sortedMatches);

        return sortedMatches;
    };

    Suggestions.prototype.fetch = function() {
        var oldSuggestions = JSON.parse(window.localStorage.getItem('suggestions'));
        if (oldSuggestions && oldSuggestions.length > 0) {
            this.reset(oldSuggestions);
        }
    };

    Suggestions.prototype.reset = function(suggestions) {
        this._suggestions = suggestions;
        for (var i = 0; i < this._suggestions.length; i++) {
            this.emit('push', this._suggestions[i]);
        }
        return this;
    };

    Suggestions.prototype.push = function(suggestion) {
        this._suggestions.push(suggestion);
        this.emit('push', suggestion);
        return this;
    };

    Suggestions.prototype.save = function() {
        log("Saving suggestions");
        // TODO go to a backend
        window.localStorage.setItem('suggestions', JSON.stringify(this._suggestions));
        return this;
    };
});
