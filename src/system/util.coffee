path	= require 'path'
fs		= require 'fs'

exports.IPv4ToLong = (str) ->
	parts = str.split '.'
	parts[0] << 24 | parts[1] << 16 | parts[2] << 8 | parts[3] << 0

exports.longToIPv4 = (l) ->
	((l >> 24) & 255) + '.' + ((l >> 16) & 255) + '.' + ((l >> 8) & 255) + '.' + ((l >> 0) & 255)

exports.rmdir = (dir) ->
	return unless fs.existsSync dir
	for file in fs.readdirSync dir
		loc = "#{dir}#{path.sep}#{file}"
		stats = fs.statSync loc
		if do stats.isDirectory
			exports.rmdir loc
		else
			fs.unlinkSync loc
	fs.rmdirSync dir