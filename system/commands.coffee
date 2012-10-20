commander	= require 'commander'
_			= require 'underscore'

defaults = exports.defaults = ->
	_.defaults exports.options,
		operations: 256
		timeout: 10000
		reporter: 'compact'
		modules: 'all'

exports.custom = (options) ->
	exports.options = options
	do defaults

exports.cli = ->
	commander.version '0.0.1'
	commander.option '-T, --targets <string>', 'List of targets (192.168.2.1-192.168.5.255)'
	commander.option '-e, --errors', 'Show inactive/errored modules'
	commander.option '-h, --empty', 'Show empty targets'
	commander.option '-o, --operations [number]', 'Amount of concurrent operations [256]'
	commander.option '-t, --timeout [number]', 'Port timeout in milliseconds [10000]'
	commander.option '-r, --reporter [string]', 'Scan reporter to use [default]'
	commander.option '-m, --modules [string]', 'Only run specified modules [all]'
	commander.parse process.argv
	exports.options = commander
	do defaults