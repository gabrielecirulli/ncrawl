request = require 'request'

class HTTP
	constructor: (@target, @options) ->
	start: (callback, prefix='http') ->
		request.get
			url: "#{prefix}://#{@target}"
			timeout: @options.timeout
			headers: 'User-Agent': 'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0)'
		, (err, res, body='') =>
			return callback error: err if err
			data = {}
			fn data, res, body for name, fn of exports.middleware
			callback { data }

exports.port = 80
exports.Module = HTTP