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
	modules.run options.modules
	queue.maxOperations options.operations

	reporter = options.reporter
	reporter = require require.resolve "../reporters/#{options.reporter}" if _.isString reporter
	do reporter.before if reporter.before

	targets	= targets options.targets unless _.isArray options.targets
	totalTargets = targets.length
	totalModules = do modules.amount

	unless reporter.error
		reporter.error = (msg) ->
			throw new Error msg

	reporter.error 'No targets selected' if totalTargets is 0
	reporter.error 'No modules selected' if totalModules is 0

	return do complete if totalTargets is 0 or totalModules is 0

	reporter.start { totalTargets, totalModules } if reporter.start

	increment = (totalModules / totalTargets) * 100 / totalModules
	progress = 0

	for i, target of targets
		do (i, target) ->
			queue.add (finished) ->
				scanReporter = new reporter.Reporter target, options
				new Scan +i, target, options, scanReporter, finished, ->
					progress += increment
					reporter.progress progress if reporter.progress
					return unless --totalTargets is 0
					do reporter.after if reporter.after
					do reporter.end if reporter.end
					do complete