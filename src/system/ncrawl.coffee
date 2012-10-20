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
	do options.before if options.before

	targets	= targets options.targets unless _.isArray options.targets
	totalTargets = targets.length
	totalModules = do modules.amount

	unless options.error
		options.error = (code, msg) ->
			throw new Error msg

	options.error 1, 'No targets selected' if totalTargets is 0
	options.error 2, 'No modules selected' if totalModules is 0

	return do complete if totalTargets is 0 or totalModules is 0

	options.start { totalTargets, totalModules } if options.start

	increment = (totalModules / totalTargets) * 100 / totalModules
	progress = 0
	lastUpdatedProgress = 0

	if options.progressInterval
		progressInterval = setInterval ->
			options.progress progress
		, options.progressInterval

	finish = ->
		clearInterval progressInterval
		do options.after if options.after
		do options.end if options.end
		do complete

	for i, target of targets
		do (i, target) ->
			queue.add (finished) ->
				scanReporter = new options.Reporter target, options
				new Scan +i, target, options, scanReporter, finished, ->
					delete targets[i]
					progress += increment
					options.progress progress if not options.progressInterval and options.progress
					do finish if --totalTargets is 0