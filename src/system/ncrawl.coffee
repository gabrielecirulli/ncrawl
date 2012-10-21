colors		= require 'colors'
fs			= require 'fs'
_			= require 'underscore'

commands	= require './commands'
modules		= require './modules'
targets		= require './targets'
Queue		= require './queue'
ports		= require './ports'
Scan		= require './scan'

module.exports = (options) ->
	commands.defaults options
	parsedModules = modules options.modules
	queue = new Queue options.operations

	reporter = options.reporter
	reporter = require require.resolve "../reporters/#{options.reporter}" if _.isString reporter
	options = _.extend options, reporter

	options.ports	= ports options.ports
	parsedTargets	= targets options.targets

	totalTargets 	= parsedTargets.length
	totalModules 	= Object.keys(parsedModules).length
	totalPorts		= options.ports.length

	unless options.error
		options.error = (code, msg) ->
			throw new Error msg

	options.error 1, 'No targets selected' if totalTargets is 0
	options.error 2, 'No modules or ports selected' if totalModules is 0 and totalPorts is 0
	return if totalTargets is 0 or totalModules is 0 and totalPorts is 0

	options.before { totalTargets, totalModules } if options.before

	startTime = do Date.now
	increment = (totalModules / totalTargets) * 100 / totalModules
	currentProgress = 0
	lastUpdatedProgress = 0
	completedScans = 0
	remainingScans = 0
	scanID = 0

	progress = ->
		return if completedScans is 0
		elapsed = do Date.now - startTime
		options.progress
			progress: currentProgress
			elapsed: elapsed
			eta: elapsed * (totalTargets / completedScans - 1)
			totalScans: totalTargets
			remainingScans: remainingScans
			completedScans: completedScans

	if options.progressInterval
		progressInterval = setInterval progress, options.progressInterval

	finish = ->
		clearInterval progressInterval
		return unless options.after
		options.after
			start: startTime
			end: do Date.now
			took: do Date.now - startTime

	scanTarget = options.scanTarget = (target, callback) ->
		id = scanID++
		remainingScans++
		options.queue id, target if options.queue
		queue.add (queueDone) ->
			new Scan
				id: id
				target: target
				options: options
				reporter: new options.Reporter target, options
				queueDone: queueDone
				totalModules: totalModules
				modules: parsedModules
				queue: queue
				done: ->
					callback @info, @results if callback
					completedScans++
					currentProgress += increment
					do progress if not options.progressInterval and options.progress
					do finish if --remainingScans is 0

	scanTarget target for target in parsedTargets