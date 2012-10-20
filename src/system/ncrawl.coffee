colors		= require 'colors'
fs			= require 'fs'
_			= require 'underscore'

commands	= require './commands'
modules		= require './modules'
targets		= require './targets'
queue		= require './queue'
Scan		= require './scan'

module.exports = (options) ->
	modules.run options.modules
	queue.maxOperations options.operations

	reporter = options.reporter
	reporter = require require.resolve "../reporters/#{options.reporter}" if _.isString reporter
	options = _.extend options, reporter

	parsedTargets	= targets.run options.targets unless _.isArray options.targets
	totalTargets 	= do targets.amount
	totalModules 	= do modules.amount

	unless options.error
		options.error = (code, msg) ->
			throw new Error msg

	options.error 1, 'No targets selected' if totalTargets is 0
	options.error 2, 'No modules selected' if totalModules is 0
	return if totalTargets is 0 or totalModules is 0

	options.before { totalTargets, totalModules } if options.before

	increment = (totalModules / totalTargets) * 100 / totalModules
	currentProgress = 0
	lastUpdatedProgress = 0
	completedScans = 0
	startTime = do Date.now

	progress = ->
		return if completedScans is 0
		elapsed = do Date.now - startTime
		options.progress
			progress: currentProgress
			elapsed: elapsed
			eta: elapsed * (totalTargets / completedScans - 1)
			totalScans: totalTargets
			completedScans: completedScans

	if options.progressInterval
		progressInterval = setInterval progress, options.progressInterval

	finish = ->
		clearInterval progressInterval
		if options.after
			options.after
				start: startTime
				end: do Date.now
				took: do Date.now - startTime

	remainingScans = totalTargets
	scanID = 0
	options.scanTarget = (target, callback) ->
		id = scanID++
		queue.add (queueDone) ->
			scanReporter = new options.Reporter target, options
			new Scan id, target, options, scanReporter, queueDone, ->
				do callback if callback
				completedScans++
				currentProgress += increment
				do progress if not options.progressInterval and options.progress
				do finish if --remainingScans is 0

	options.scanTarget target for target in parsedTargets