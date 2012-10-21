async	= require 'async'
dns		= require 'dns'
net		= require 'net'
_		= require 'underscore'

class Scan
	constructor: (o) ->
		@id = o.id
		@target = o.target
		@options = o.options
		@reporter = o.reporter
		@queueDone = o.queueDone
		@modules = o.modules
		@done = o.done
		@queue = o.queue

		@call 'start', @id, @target
		@totalModules = o.totalModules

		@results = {}
		@results[name] = error: true for name, module of @modules

		@info =
			target: @target
			id: @id
			type: []
			mx: []
			txt: []
			srv: []
			ns: []
			cname: []
			resolve: {}
			isIP: false
			ip: null
			hostname: null
			
		if net.isIP @target
			@info.isIP = true
			@info.ip = @target
		else
			@info.hostname = @target

		@dns =>
			@call 'info', @info
			@addModule name, module for name, module of @modules
			@addPort port for port in @options.ports
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
				return next @results = {} unless @info.ip
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
	identify: (device) ->
		@info.type.push device
		@call 'identify', { device, @id }
	addModule: (name, obj) ->
		@queue.add (finished) =>
			start = do Date.now
			@checkPort obj.port, (error) =>
				if error
					@scanDone name,
						module: name
						port: obj.port
						error: true
						start: start
						finish: do Date.now
						took: do Date.now - start
					do finished
				else
					@startModule name, obj, finished
	addPort: (port) ->
		@queue.add (finished) =>
			start = do Date.now
			@checkPort port, (error) =>
				@scanDone 'port',
					port: port
					error: error
					start: start
					finish: do Date.now
					took: do Date.now - start
				do finished
	checkPort: (port, callback) ->
		socket = new net.Socket
		error = true

		next = =>
			do socket.destroy
			clearTimeout timeout
			callback error

		socket.on 'connect', ->
			error = false
			do socket.destroy

		timeout = setTimeout next, @options.timeout
		socket.on 'error', ->
		socket.on 'close', next
		socket.connect port, @target
	startModule: (name, obj, finished) ->
		start = do Date.now
		module = new obj.Module @target, @options, @identify.bind @
		module.start (result={}) =>
			result.port = obj.port
			result.finish = do Date.now
			result.start = start
			result.took = result.finish - result.start

			for device, types of obj.identities
				for check, values of types
					continue unless result.data and data = result.data[check]
					for val in values
						reg = new RegExp val, 'i'
						@identify device if reg.test data

			do finished
			
			@scanDone name, result
	scanDone: (name, result={}) ->
		result.module = name
		result.id = @id
		result.data = result.data or {}
		if not result.error or result.error and @options.errors
			@results[name] = result
			@call 'result', name, result
		else
			delete @results[name]
		do @finish if --@totalModules is 0
	finish: ->
		return do @done if Object.keys(@results).length is 0 and not @options.empty
		@call 'finish', @id, @info, @results
		do @done

module.exports = Scan