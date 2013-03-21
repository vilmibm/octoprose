Error = (@msg = 'unknown error', @type = 'error', @code = 500) -> @
Error::finish = (res) ->
    console.error @type, @msg
    res.send @code, {msg:@msg, type:@type}

NotFoundError = (identifier) ->
    @type = 'not_found'
    @msg = "not found: #{identifier}"
    @code = 404
NotFoundError extends Error

DBError = (e) ->
    @type = 'db_err'
    @msg = "db error: #{e}"
    @code = 500
DBError extends Error

PermError = (u, i) ->
    @type = 'permission_error'
    @msg = "#{u} cannot modify #{i}"
    @code = 403
PermError extends Error

ValidationError = (value, wanted) ->
    @type = 'validation_error'
    @msg = "got #{value}, wanted #{wanted}"
    @code = 400
ValidationError extends Error

exports.Error = Error
exports.DBError = DBError
exports.NotFoundError = NotFoundError
exports.PermError = PermError
exports.ValidationError = ValidationError
