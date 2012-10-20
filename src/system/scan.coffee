async	= require 'async'
dns		= require 'dns'
net		= require 'net'
_		= require 'underscore'

modules	= require './modules'
queue	= require './queue'

class Scan
	constructor: (@id, @target, @options, @reporter, @queueDone, @done) ->
		@totalModules = do modules.amount

		@results = {}
		@results[name] = error: true for name, module of modules.modules

		@info =
			target: @target
			id: @id
			mx: []
			txt: []
			srv: []
			ns: []
			cname: []
			resolve: {}
			ip: null
			hostname: null
		if net.isIP @target
			@info.isIP = true
			@info.ip = @target
			@info.hostname = null
		else
			@info.isIP = false
			@info.ip = null
			@info.hostname = @target

		@dns =>
			@call 'info', @info
			@add name, module for name, module of modules.modules
	call: (name, args...) ->
		@reporter[name].apply @reporter, args if _.isFunction @reporter[name]
		@options[name].apply @options, args if _.isFunction @options[name]
	dns: (finish) ->
		next = =>
			do @queueDone
			do finish
		async.series
			reverse: (callback) =>
				dns.resolve @target, (err, results) =>
					return do callback if err
					@info.ip = results[0] if results and not @info.ip
					@info.resolve = {}
					async.forEach results, (item, done) =>
						dns.reverse item, (err, results) =>
							@info.hostname = results[0] if results and not @info.hostname
							@info.resolve[item] = results
							do done
					, callback
			mx: (callback) =>
				unless @info.ip
					@results = {}
					do @queueDone
					return do @finish
				return do next unless @info.hostname
				dns.resolveMx @info.hostname, (err, records) =>
					@info.mx = records if records
					do callback
			txt: (callback) =>
				dns.resolveTxt @info.hostname, (err, records) =>
					@info.txt = records if records
					do callback
			srv: (callback) =>
				dns.resolveSrv @info.hostname, (err, records) =>
					@info.srv = records if records
					do callback
			ns: (callback) =>
				dns.resolveNs @info.hostname, (err, records) =>
					@info.ns = records if records
					do callback
			cname: (callback) =>
				dns.resolveCname @info.hostname, (err, records) =>
					@info.cname = records if records
					do callback
			next: next
	identify: (type) ->
		@info.type = [] unless @info.type
		@info.type.push type
		@call 'identify', { type, @id }
	add: (name, obj) ->
		queue.add (finished) =>
			start = do Date.now
			module = new obj.Module @target, @options, @identify.bind @
			module.start (result={}) =>
				result.finish = do Date.now
				result.start = start
				result.took = result.finish - result.start
				result.id = @id
				result.port = obj.port
				result.module = name

				do finished
				if not result.error or result.error and @options.errors
					@results[name] = result
					@call 'result', name, result
				else
					delete @results[name]
				do @finish if --@totalModules is 0
	finish: ->
		return do @done if Object.keys(@results).length is 0 and not @options.empty
		@call 'finish', @info, @results, @id
		do @done

module.exports = Scan