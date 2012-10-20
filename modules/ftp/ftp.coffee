FTPClient = require 'ftp'

class FTP
	constructor: (@target, @options) ->
	start: (callback) ->
		ftp = new FTPClient
			host: @target
			connTimeout: @options.timeout
		ftp.on 'error', (err) ->
			do ftp.end
			callback error: err
		ftp.on 'timeout', ->
			do ftp.end
			callback error: true
		ftp.on 'connect', ->
			ftp.auth (err) ->
				do ftp.end
				callback
					data:
						Anonymous: if err then 'false' else 'true'
		do ftp.connect

exports.port = 21
exports.Module = FTP