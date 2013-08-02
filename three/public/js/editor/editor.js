// preamble
var EDITORHEIGHTRATIO = '.5';
var d = document;
var m2h = markdown.toHTML.bind(markdown);

// Open edit pane

var $editButton = $("#openEditor");

var setEditorHeight = function(root) {
    var windowHeight = window.innerHeight;
    var editorHeight = windowHeight * EDITORHEIGHTRATIO;
    console.log("Setting", root, "height to", editorHeight);
    root.style.height = String(editorHeight) + "px";

    return true;
};

var openEditor = function(e) {
    // TODO global
    var $root = $("#editorContainer");
    var root  = d.getElementById("editorContainer");

    setEditorHeight(root);
    
    var rawText = $("#text").text();
    var ta = d.querySelector("#editorContainer textarea");
    ta.value = rawText;
    ta.style.width = "100%";
    ta.style.height = "90%";

    var editButton = d.querySelector("#openEditor");
    editButton.style.display = "none";
    
    root.style.display = "block";

    return false;
};

var originalFun;
if (window.onresize) {
    originalFun = window.onresize;
}
else {
    originalFun = function() {};
}

window.onresize = function() {
    console.log("RESIZE");
    originalFun();
    return setEditorHeight(document.getElementById("editorContainer"));
};

$editButton.click(openEditor);

var $closeButton = $("#closeEditor");

var closeEditor = function(e) {
    var root = d.getElementById("editorContainer");
    root.style.display = "none";

    var editButton = d.querySelector("#openEditor");
    editButton.style.display = "block";

    var ta = d.querySelector
    ta.value = '';

    return false;
};

$closeButton.click(closeEditor);

$editButton.click();
