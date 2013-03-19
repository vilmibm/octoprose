mg = require('mongoose')
mg.connect('mongodb://localhost/octoprose_dev')
Schema = mg.Schema
ref = (model) -> {type:Schema.ObjectId, ref:model}

setCreated = (n) ->
    @created = @_id.getTimestamp() unless @created
    n()

SignupRequestSchema = new Schema(
    username: {type:String, index:true}
    email: {type:String}
    password: String
    info: String
    searchable: {type:Boolean, default:false}
    show_email: {type:Boolean, default:false}
    url: String
)

UserSchema = new Schema(
    username: {type:String, index:true}
    email: {type:String}
    # TODO obviously, sha this.
    password: String
    flags: {type:Number, default:0}
    made: {type:Number, default:0}
    accepted: {type:Number, default:0}
    rejected: {type:Number, default:0}
    info: String
)

SuggestionSchema = new Schema(
    status: {type: String, default: 'new'}
    stext: String
    _user: ref 'User'
    _range: ref 'Range'
    _revision: ref 'Revision'
)
SuggestionSchema.pre 'save', setCreated

RangeSchema = new Schema(
    offset: {type:Number, required:true}
    length: {type:Number, required:true}
    suggestions: [ref 'Suggestion']
    _revision: ref 'Revision'
)

RevisionSchema = new Schema(
    idx: {type:Number, default:1}
    content: {type:String, default:''}
    ranges: [ref 'Range']
    _text: ref 'Text'
)

TextSchema = new Schema(
    _user: ref 'User'
    uuid: {type:String, required:true}
    category: {type:String, default:'no category'}
    #category_slug: {type:String, default:'no-category'}
    created: {type:Date}
    desc: {type:String, required:true}
    revisions: [ref 'Revision']
)
TextSchema.pre 'save', setCreated

exports.User = mg.model('User', UserSchema)
exports.Suggestion = mg.model('Suggestion', SuggestionSchema)
exports.Range = mg.model('Range', RangeSchema)
exports.Text = mg.model('Text', TextSchema)
exports.Revision = mg.model('Revision', RevisionSchema)
exports.SignupRequest = mg.model('SignupRequest', SignupRequestSchema)

# for use in repl; coffee -r './models'
global.User = exports.User
global.Suggestion = exports.Suggestion
global.Range = exports.Range
global.Text = exports.Text
global.Revision = exports.Revision
global.SignupRequest = exports.SignupRequest
