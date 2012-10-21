request = require 'request'

class HTTP
	constructor: (@target, @options) ->
	start: (callback, prefix='http') ->
		request.get
			url: "#{prefix}://#{@target}"
			timeout: @options.timeout
			headers: 'User-Agent': @options.httpUserAgent
		, (err, res, body='') =>
			return callback error: true if err
			exports.runMiddleware res, body, callback

exports.description = 'HTTP module'
exports.port = 80
exports.Module = HTTP

exports.commands = (commander, defaults) ->
	defaults.httpUserAgent = 'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0)'
	commander.option '--http-user-agent [string]', "User agent to use for the HTTP module [#{defaults.httpUserAgent}]"