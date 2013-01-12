Error = (msg, type) ->
    @.msg = msg or 'unknown error'
    @.type = type or 'error'
    @.code = 500
    return @
Error::finish = (res) -> res.send({msg:@.msg, type:@.type}, @.code)

NotFoundError = (identifier) ->
    @.type = 'not_found'
    @.msg = "not found: #{identifier}"
    @.code = 404
NotFoundError extends Error

DBError = (e) ->
    @.type = 'db_err'
    @.msg = "db error: #{e}"
    @.code = 500
DBError extends Error

PermError = (u, i) ->
    @.type = 'permission_error'
    @.msg = "#{u} cannot modify #{i}"
    @.code = 403
PermError extends Error

ValidationError = (value, wanted) ->
    @.type = 'validation_error'
    @.msg = "got #{value}, wanted #{wanted}"
    @.code = 400
ValidationError extends Error

exports.Error = Error
exports.NotFoundError = NotFoundError
exports.PermError = PermError
exports.ValidationError = ValidationError
