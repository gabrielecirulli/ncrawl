commander	= require 'commander'
_			= require 'underscore'

defaults = exports.defaults = ->
	_.defaults exports.options,
		operations: 384
		timeout: 2000
		reporter: 'compact'
		modules: 'all'

exports.custom = (options) ->
	exports.options = options
	do defaults

exports.cli = ->
	commander.version '0.0.1'
	commander.option '-T, --targets <string>', 'List of targets (192.168.2.1-192.168.5.255)'
	commander.option '-e, --errors', 'Show errored modules'
	commander.option '-h, --empty', 'Show empty targets'
	commander.option '-o, --operations [number]', 'Amount of concurrent operations [256]'
	commander.option '-t, --timeout [number]', 'Module timeout in milliseconds [2000]'
	commander.option '-r, --reporter [string]', 'Reporter to use [default]'
	commander.option '-m, --modules [comma delimetered string]', 'Only run specified modules [all]'
	commander.parse process.argv
	return do commander.help unless commander.targets
	exports.options = commander
	do defaults