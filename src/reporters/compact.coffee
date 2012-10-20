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