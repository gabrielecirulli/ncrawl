HTTP = require '../http/http'

class HTTPS
	port: 443
	constructor: (target, options, identify) ->
		@http = new HTTP.Module target, options, identify
	start: (callback) ->
		@http.start callback, 'https'

exports.port = 443
exports.Module = HTTPS