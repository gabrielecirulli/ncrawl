{EventEmitter2}	= require 'eventemitter2'
colors			= require 'colors'
fs				= require 'fs'
_s				= require 'underscore.string'
_				= require 'underscore'

commands		= require './commands'
modules			= require './modules'
targets			= require './targets'
Queue			= require './queue'
ports			= require './ports'
Scan			= require './scan'

totalSessions = 0

module.exports = (options) ->
	class NCrawl extends EventEmitter2
		constructor: (@options) ->
			@sessionID = totalSessions++

			commands.defaults @options
			@queue = new Queue @options.operations

			require("../reporters/#{@options.reporter}") @ if @options.reporter

			@modules = modules @options.modules
			@totalModules = Object.keys(@modules).length
			@emit 'modules parsed', { @sessionID, @modules }

			@targets = targets @options.targets
			@totalTargets = @targets.length
			@emit 'targets parsed', { @sessionID, @targets }

			@ports = ports @ports
			@totalPorts = @ports.length
			@emit 'ports parsed', { @sessionID, @ports }

			@error 1, 'No targets selected' if @totalTargets is 0
			@error 2, 'No modules or ports selected' if @totalModules is 0 and totalPorts is 0
			return if @totalTargets is 0 or @totalModules is 0 and totalPorts is 0

			@startTime = do Date.now
			@completedScans = 0
			@remainingScans = 0
			@totalScans = 0
			@results = []
			@scans = {}

			do @progress
			@on 'stop scan', @stopScan
			@on 'stop session', @stopSession
			@on 'new scan', @newScan
			@emit 'new scan', target for target in @targets
			@emit 'session start', { @sessionID, @targets, @ports, @totalTargets, @totalModules }
		stopSession: ->
			do scan.stop for id, scan of @scans
		stopScan: (scanID) =>
			if @scans[scanID]
				do @scans[scanID].stop
			else
				@error 3, 'Scan not found' ,false
		newScan: (target, callback) ->
			scanID = @totalScans++
			@remainingScans++
			@emit 'scan queued', { scanID, @sessionID, target }
			@queue.add (queueDone) =>
				@scans[scanID] = scan = new Scan
					scanID: scanID
					sessionID: @sessionID
					target: target
					options: @options
					ports: @ports
					queueDone: queueDone
					totalModules: @totalModules
					modules: @modules
					queue: @queue
				self = @
				scan.onAny ->
					listener.apply scan, arguments for listener in self.listeners @event
				scan.on 'scan finish', (info, results) =>
					@completedScans++
					@currentProgress += @progressIncrement
					@results.push { info, results }
					return unless --@remainingScans is 0
					@endTime = do Date.now
					@emit 'session finish',
						start: @startTime
						end: @endTime
						took: @endTime - @startTime
						sessionID: @sessionID
						results: @results
		progress: ->
			@progressIncrement = (@totalModules / @totalTargets) * 100 / @totalModules
			@currentProgress = 0
			lastUpdatedProgress = 0

			progressInterval = setInterval =>
				return if lastUpdatedProgress is @currentProgress
				lastUpdatedProgress = @currentProgress
				elapsed = do Date.now - @startTime
				@emit 'session progress',
					sessionID: @sessionID
					progress: @currentProgress
					elapsed: elapsed
					eta: elapsed * (@totalTargets / @completedScans - 1)
					totalScans: @totalScans
					remainingScans: @remainingScans
					completedScans: @completedScans
			, 2000

			@on 'session finish', ->
				clearInterval progressInterval
		error: (code, message, fatal=true) ->
			err = new Error message
			err.code = code
			err.fatal = fatal
			@emit 'error', err
		enable: (key) ->
			@set key, true
		disable: (key) ->
			@set key, false
		set: (key, value) ->
			key = _s.camelize key.replace ' ', '-'
			@options[key] = value

	new NCrawl options