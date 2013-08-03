ensure($,
       Reviewer,
       Editor,
       Text);

var rawText = $("#text").text();

var text     = new Text(    rawText);
var reviewer = new Reviewer(document.getElementById("reviewerContainer"), text);
var editor   = new Editor(  document.getElementById("editorContainer"), text);

rawText.suggestions.fetch();

window.addEventListener('unload', text.suggestions.save.bind(text.suggestions));
