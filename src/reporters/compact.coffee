_s	= require 'underscore.string'
_	= require 'underscore'

module.exports = (n) ->
	n.on 'target info', (@info) ->
		alias = []
		alias.push @info.hostname if @info.hostname
		alias.push @info.ip if @info.ip
		@alias = if alias.length is 0 then '' else alias.join ':'

	n.on 'module result', (result) ->
		color = if result.error then 'red' else 'green'
		alias = @alias
		alias += ' - ' if alias
		console.log "   #{alias}#{result.module} - #{result.took}ms"[color]
		for name, value of result.data
			value = value.join ', ' if _.isArray value
			console.log " > #{_s.capitalize name}: #{value}"
		do console.log

	n.on 'target identify', (data) ->
		console.log "#{@alias} has been identified as #{data.device}".bold
		do console.log

	n.on 'session progress', (data) ->
		percent = Math.floor data.progress
		width = 20
		length = Math.round width * data.progress / 100
		bar = ''
		bar += _s.repeat '=', length
		bar += _s.repeat ' ', width - length
		console.log "    progress [#{bar}] #{percent}% #{(data.eta / 1000).toFixed 1}s #{data.remainingScans} scans left"
		do console.log