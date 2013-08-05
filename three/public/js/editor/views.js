ensure('$');

var Resizable;
scope(function() {
    Resizable = function() {};
    Resizable.prototype.resize = function(ratio) {
        if (!ratio) {
            throw "Ratio required";
        }
        var newHeight = String(ratio * window.innerHeight) + "px";
        log("Setting", this.root, "height to", newHeight);
        this.root.style.height = newHeight;

        return this;
    };
});

var Reviewer;
scope(function () {
    var selection = window.getSelection(); // this function returns a singleton reference

    // States for spanify
    var INEL  = 1;
    var INTXT = 2;
    var INENT = 3;

    // String-munging porcelain over CSS's rgba()
    var RGBA = function(r, g, b, a) {
        this.r = r || 0;
        this.g = g || 0;
        this.b = b || 0;
        this.a = a || 1;
    };

    RGBA.prototype.toString = function() {
        return 'rgba('+this.r+','+this.g+','+this.b+','+this.a+')';
    };

    RGBA.prototype.clone = function() {
        return new RGBA(this.r, this.g, this.b, this.a);
    };

    RGBA.prototype.opaquen = function() {
        var newRGBA = this.clone();
        newRGBA.a = newRGBA.a + .1;
        return newRGBA;
    };

    RGBA.fromString = function(string) {
        var commaSep = string
            .replace('rgba(', '')
            .replace(')', '')
            .split(',');
        var toNumber = function(str) {
            return Number(str.replace(/ /g, ''));
        };
        var r = toNumber(commaSep[0]);
        var g = toNumber(commaSep[1]);
        var b = toNumber(commaSep[2]);
        var a = toNumber(commaSep[3]);

        return new RGBA(r, g, b, a);
    };

    // Used for red highlight
    var BASEBGCOLOR = new RGBA(255, 0, 0, .1);

    Reviewer = mixin(function(root, piece) {
        this.root = root;
        this.piece = piece;

        this.root.style.overflow = "scroll";

        this.root.addEventListener('mouseup', this.handleHighlight.bind(this));
        $(this.root).on(           'click',   'span.highlight', this.handleSuggestionClick.bind(this));
        this.piece.suggestions.on(  'push',    this.handleSuggestion.bind(this));
        this.piece.on(              'update',  this.render.bind(this));

    }, [EventEmitter, 'on', 'emit'], [Resizable, 'resize']);

    Reviewer.prototype.render = function() {
        this.root.innerHTML = this.spanify(this.piece.getMarkdownText());
        return this.root;
    };

    Reviewer.prototype.handleSuggestionClick = function(e) {
        var span = e.target;
        if ( ! $(span).hasClass('highlight') ) {
            log("Click not on a suggestion");
            return true;
        }

        // TODO ask for comment
        var commentText = "Science and Magic " + String(Math.floor(100*Math.random()));

        if (commentText.length === 0) {
            log("No comment entered, moving on");
            return;
        }

        var idx = Number(span.dataset.idx);
        var suggestion = this.piece.suggestions.findByIdx(idx).pop();

        log("Adding comment to:", suggestion);

        suggestion.comments.push({text:commentText});

        return true;
    };

    Reviewer.prototype.handleSuggestion = function(suggestion) {
        var rangeTuple = suggestion.range;

        log("New range:", rangeTuple);

        var lidx = rangeTuple[0];
        var ridx = rangeTuple[1];

        var span, bgColor;

        for (var idx = lidx; idx <= ridx; idx++) {
            span = this.root.querySelector('span[data-idx="'+idx+'"]');
            if (span.style.backgroundColor.length === 0) {
                bgColor = BASEBGCOLOR;
            }
            else {
                bgColor = RGBA.fromString(span.style.backgroundColor).opaquen();
            }

            span.style.backgroundColor = bgColor.toString();

            $(span).addClass('highlight');
        }

        return true;
    };

    Reviewer.prototype.handleHighlight = function() {
        var selectedText = selection.toString();
        if (selectedText.length === 0) {
            log('Empty selection');
            return;
        }

        log('Selected text:', selectedText);

        var anchorIdx = Number(selection.anchorNode.parentElement.dataset['idx']);
        var focusIdx  = Number(selection.focusNode.parentElement.dataset['idx' ]);

        selection.collapseToStart(); // clear selection

        // TODO ask for suggestion with modal
        var suggestionText = "The palatable comb " + String(Math.floor(100*Math.random()));

        if (!suggestionText) {
            log("No suggestion. Moving on");
            return;
        }

        this.piece.suggestions.push(
            new Suggestion({text:     suggestionText,
                            selected: selectedText,
                            range:    [anchorIdx, focusIdx]}));
    };

    Reviewer.prototype.spanify = function(html) {
        var idx = 0; // span index
        var state;
        var ch, cix; // character, character index

        var newHTML = '';

        for (var cix = 0; cix < html.length; cix++) {
            ch = html[cix];
            if (ch == '<') {
                state = INEL;
            }
            else if (ch == '>' && state == INEL) {
                state = INTXT;
            }
            else if (ch == '&' && state == INTXT) {
                state = INENT;
                newHTML += '<span data-idx="' + idx++ + '">';
            }
            else if (ch == ';' && state == INENT) {
                newHTML += ch;
                newHTML += '</span>';
                state = INTXT;
                continue;
            }
            else if (state == INTXT) {
                newHTML += '<span data-idx="'+ idx++ +'">'+ch+'</span>';
                continue;
            }
            newHTML += ch;
        }

        return newHTML;
    };
});

var Editor;
scope(function() {
    Editor = mixin(function(root, piece) {
        this.root  = root;
        this.$root = $(root);
        this.piece  = piece;

        this.hidden = true;

        this.root.querySelector('#showEditor').addEventListener('click', this.showEditor.bind(this));
        this.root.querySelector('#hideEditor').addEventListener('click', this.hideEditor.bind(this));
    }, [EventEmitter, 'on', 'emit'], [Resizable, 'resize']);

    Editor.prototype.showEditor = function() {
        this.hidden = false;
        var ta = this.$root.find('textarea')[0];
        ta.value = piece.getRawText();
        ta.style.width = "100%";
        ta.style.height = "90%";
        ta.style.display = "block";

        var controls = this.$root.find('.controls')[0];
        controls.style.display = "block";

        var showButton = this.$root.find('button#showEditor')[0];
        showButton.style.display = "none";
        this.emit('show');
    };

    Editor.prototype.hideEditor = function() {
        this.emit('hide');
        this.hidden = true;
        var showButton = this.$root.find('button#showEditor')[0];
        showButton.style.display = "block";

        var controls = this.$root.find('.controls')[0];
        controls.style.display = "none";

        var ta = this.$root.find('textarea')[0];
        ta.style.display = 'none';
        ta.value = '';
    };
});
