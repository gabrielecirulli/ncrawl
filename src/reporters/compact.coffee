_s = require 'underscore.string'

class Reporter
	info: (@info) ->
		alias = []
		alias.push @info.hostname if @info.hostname
		alias.push @info.ip if @info.ip
		@alias = if alias.length is 0 then '' else alias.join ':'
	identify: (data) ->
		console.log "#{@alias} has been identified as #{data.type}".bold
		do console.log
	result: (name, result) ->
		color = if result.error then 'red' else 'green'
		alias = @alias
		alias += ' - ' if alias
		console.log "   #{alias}#{name} - #{result.took}ms"[color]
		for name, value of result.data
			console.log " > #{_s.capitalize name}: #{value}"
		do console.log

exports.Reporter = Reporter

exports.progressInterval = 5000
exports.progress = (data) ->
	percent = Math.floor data.progress
	width = 20
	length = Math.round width * data.progress / 100
	bar = ''
	bar += _s.repeat '=', length
	bar += _s.repeat ' ', width - length
	console.log "    progress [#{bar}] #{percent}% #{(data.eta / 1000).toFixed 1}s #{data.totalScans - data.completedScans} scans left"
	do console.log