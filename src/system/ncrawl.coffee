colors		= require 'colors'
fs			= require 'fs'
_			= require 'underscore'

commands	= require './commands'
modules		= require './modules'
targets		= require './targets'
queue		= require './queue'
Scan		= require './scan'

do process.stdin.resume

module.exports = (options, complete) ->
	complete = options.finish if options.finish
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

	return do complete if totalTargets is 0 or totalModules is 0

	options.before { totalTargets, totalModules } if options.before

	increment = (totalModules / totalTargets) * 100 / totalModules
	currentProgress = 0
	lastUpdatedProgress = 0
	completedScans = 0
	startTime = do Date.now

	progress = ->
		return if completedScans is 0
		elapsed = do Date.now - startTime
		eta = ((elapsed * (totalTargets / completedScans - 1)) / 1000).toFixed 1
		options.progress
			progress: currentProgress
			elapsed: elapsed
			eta: eta
			totalScans: totalTargets
			completedScans: completedScans

	if options.progressInterval
		progressInterval = setInterval progress, options.progressInterval

	finish = ->
		clearInterval progressInterval
		data =
			start: startTime
			end: do Date.now
			took: do Date.now - startTime
		options.after data if options.after
		do complete

	remainingScans = totalTargets
	for i, target of parsedTargets
		do (i, target) ->
			queue.add (finished) ->
				scanReporter = new options.Reporter target, options
				new Scan +i, target, options, scanReporter, finished, ->
					completedScans++
					currentProgress += increment
					do progress if not options.progressInterval and options.progress
					do finish if --remainingScans is 0