FTPClient = require 'ftp'

class FTP
	constructor: (@target, @options) ->
	start: (callback) ->
		ftp = new FTPClient
			host: @target
			connTimeout: @options.timeout
		result = error: true
		timeout = setTimeout ->
			do ftp.end
		, @options.timeout * 2
		ftp.on 'error', (err) ->
			do ftp.end
		ftp.on 'timeout', ->
			do ftp.end
		ftp.on 'close', ->
			clearTimeout timeout
			callback result
		ftp.on 'connect', ->
			ftp.auth (err) ->
				result =
					data:
						anonymous: if err then 'false' else 'true'
				do ftp.end
					
		do ftp.connect

exports.description = 'FTP module'
exports.port = 21
exports.Module = FTP