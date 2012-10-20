async	= require 'async'
dns		= require 'dns'
net		= require 'net'

modules	= require './modules'
queue	= require './queue'

class Scan
	constructor: (@id, @target, @options, @reporter, @queueDone, @done) ->
		@totalModules = do modules.amount
		
		@results = {}
		@results[name] = error: true for name, module of modules.modules

		@info = target: @target, id: @id
		if net.isIP @target
			@info.isIP = true
			@info.ip = @target
			@info.hostname = null
		else
			@info.isIP = false
			@info.ip = null
			@info.hostname = @target

		@dns =>
			@reporter.info @info if @reporter.info
			@add name, module for name, module of modules.modules
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
				do callback
			txt: (callback) ->
				do callback
			srv: (callback) ->
				do callback
			ns: (callback) ->
				do callback
			cname: (callback) ->
				do callback
			next: next
	identify: (type) ->
		@info.type = [] unless @info.type
		@info.type.push type
		@reporter.identify { type, @id } if @reporter.identify
	add: (name, obj) ->
		queue.add (finished) =>
			start = do Date.now
			module = new obj.Module @target, @options, @identify.bind @
			module.start (data={}) =>
				data.finish = do Date.now
				data.start = start
				data.took = data.finish - data.start
				data.id = @id
				data.port = obj.port
				data.module = name

				do finished
				if not data.error or data.error and @options.errors
					@results[name] = data
					@reporter.result name, data if @reporter.result
				else
					delete @results[name]
				do @finish if --@totalModules is 0
	finish: ->
		return do @done if Object.keys(@results).length is 0 and not @options.empty
		@reporter.finish @info, @results, @id if @reporter.finish
		do @done

module.exports = Scan