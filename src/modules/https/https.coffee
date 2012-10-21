HTTP = require '../http/http'

class HTTPS
	port: 443
	constructor: (target, options) ->
		@http = new HTTP.Module target, options
	start: (callback) ->
		@http.start callback, 'https'

exports.description = 'HTTPS module'
exports.port = 443
exports.Module = HTTPS