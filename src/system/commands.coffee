commander	= require 'commander'
_			= require 'underscore'

exports.defaults = (options) ->
	_.defaults options,
		operations: 512
		timeout: 2000
		reporter: 'compact'
		modules: 'all'

exports.cli = ->
	commander.version '0.0.1'
	commander.option '-T, --targets <string>', 'List of targets (192.168.2.1-192.168.5.255)'
	commander.option '-e, --errors', 'Show errored modules'
	commander.option '-h, --empty', 'Show empty targets'
	commander.option '-o, --operations [number]', 'Amount of concurrent operations [512]'
	commander.option '-t, --timeout [number]', 'Module timeout in milliseconds [2000]'
	commander.option '-r, --reporter [string]', 'Reporter to use [default]'
	commander.option '-m, --modules [comma delimetered string]', 'Only run specified modules [all]'
	commander.option '-p, --ports [comman delimetered string]', 'Additional ports youd like scanned'
	commander.parse process.argv
	return do commander.help unless commander.targets
	commander