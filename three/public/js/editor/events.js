var EventEmitter = function() {};
EventEmitter.prototype.on = function(e, callback) {
    if (!this._callbacks) {
        this._callbacks = {};
    }
    if (!this._callbacks[e]) {
        this._callbacks[e] = [];
    }

    this._callbacks[e].push(callback);

    return this;
}

EventEmitter.prototype.emit = function(e, data) {
    for (var i = 0; i < this._callbacks[e].length; i++) {
        this._callbacks[e][i].call(this, data);
    }
    return this;
};
