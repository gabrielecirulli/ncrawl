HTTP = require '../http/http'

class HTTPS
	port: 443
	constructor: (target, options) ->
		@http = new HTTP.Module target, options
	start: (callback) ->
		@http.start callback, 'https'

exports.port = 443
exports.Module = HTTPS