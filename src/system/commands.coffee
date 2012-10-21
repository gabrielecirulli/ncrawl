commander	= require 'commander'
path		= require 'path'
fs			= require 'fs'
_s			= require 'underscore.string'
_			= require 'underscore'

defaults =
	operations: 512
	timeout: 2000
	reporter: 'compact'
	modules: 'all'

exports.defaults = (options) ->
	_.defaults options, defaults

exports.cli = ->
	commander.version '0.0.1'
	commander.option '-T, --targets [string]', 'List of targets (192.168.2.1-192.168.5.255)'
	commander.option '-m, --modules [string]', "Only run specified modules - comma delimetered [#{defaults.modules}]"
	commander.option '-p, --ports [string]', 'Additional ports youd like scanned - comma delimetered'
	commander.option '-o, --operations [number]', "Amount of concurrent operations [#{defaults.operations}]"
	commander.option '-t, --timeout [number]', "Module timeout in milliseconds [#{defaults.timeout}]"
	commander.option '-r, --reporter [string]', "Reporter to use [#{defaults.reporter}]"
	commander.option '-e, --errors', 'Show errored modules'
	commander.option '-h, --empty', 'Show empty targets'

	modules = {}
	modulesDir = "#{__dirname}/../modules"
	modules[file] = require "#{modulesDir}/#{file}/#{file}" for file in fs.readdirSync modulesDir

	generators = {}
	generatorsDir = "#{__dirname}/../generators"
	for file in fs.readdirSync generatorsDir
		name = path.basename file, path.extname file
		generators[name] = require "#{generatorsDir}/#{file}"

	commander.on '--help', ->
		section = (header, lines) ->
			console.log "  #{header}:"
			do console.log
			console.log "    #{line}" for line in lines
			do console.log

		section 'Modules', ("#{_s.rpad name, 27} #{module.description}" for name, module of modules)
		section 'Generators', ("#{_s.rpad name, 27} #{generator.description}" for name, generator of generators)
		section 'Examples', ['$ ncrawl -T localhost']

	objs = _.extend _.clone(modules), generators
	for name, obj of objs
		obj.commands commander, defaults if obj.commands

	commander.parse process.argv
	return do commander.help unless commander.targets
	commander