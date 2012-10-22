{EventEmitter2}	= require 'eventemitter2'
services		= require './services'
async			= require 'async'
dns				= require 'dns'
net				= require 'net'
_				= require 'underscore'

class Scan extends EventEmitter2
	constructor: (o) ->
		@[key] = value for key, value of o

		@completedModules = 0
		@remainingModules = @totalModules

		@currentProgress = 0
		@lastUpdatedProgress = 0
		@progressIncrement = @totalModules * 100 / @totalModules

		@emit 'scan start', { @sessionID, @scanID, @target }

		@startTime = do Date.now
		@results = {}
		@results[name] = error: true for name, module of @modules

		@progressInterval = setInterval =>
			return if @lastUpdatedProgress is @currentProgress
			@lastUpdatedProgress = @currentProgress
			elapsed = do Date.now - @startTime
			@emit 'scan progress',
				sessionID: @sessionID
				scanID: @scanID
				progress: @currentProgress
				elapsed: elapsed
				eta: elapsed * (@totalModules / @completedModules - 1)
				remainingModules: @remainingModules
				completedModules: @completedModules
		, 2000

		@info =
			target: @target
			scanID: @scanID
			sessionID: @sessionID
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
			@emit 'target info', @info
			@addModule name, module for name, module of @modules
			@addPort port for port in @ports
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
		@emit 'target identify', { device, @scanID, @sessionID }
	addModule: (name, obj) ->
		@queue.add (finished) =>
			start = do Date.now
			@checkPort obj.port, (error) =>
				return do finished if @stopped
				if error
					@moduleDone name,
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
				return do finished if @stopped
				info = services.getByPort port
				@moduleDone info.name or 'port',
					port: port
					data: port: port
					error: error
					start: start
					finish: do Date.now
					took: do Date.now - start
				do finished
	checkPort: (port, callback) ->
		return do callback if @stopped
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
	stop: ->
		@stopped = true
	cleanUp: (callback) ->
		clearInterval @progressInterval
		do callback if callback
	startModule: (name, obj, finished) ->
		return @cleanup finished if @stopped
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
					reg = new RegExp "(#{values.join '|'}})", 'i'
					@identify device if reg.test data

			do finished
			
			@moduleDone name, result
	moduleDone: (name, result={}) ->
		@currentProgress += @progressIncrement
		@remainingModules--
		@completedModules++
		result.module = name
		result.scanID = @scanID
		result.sessionID = @sessionID
		result.data = result.data or {}
		if not result.error or result.error and @options.errors
			@results[name] = result
			@emit 'module result', result
		else
			delete @results[name]
		return unless --@totalModules is 0
		do @cleanUp
		@finishTime = do Date.now
		@emit 'scan finish',
			info: @info
			results: @results
			start: @startTime
			finish: @finishTime
			took: @finishTime - @startTime

module.exports = Scan