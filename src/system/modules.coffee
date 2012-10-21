path	= require 'path'
fs		= require 'fs'
_		= require 'underscore'

modules = exports.modules = {}
exports.run = (enabled=['all']) ->
	enabled = enabled.split ',' if _.isString enabled
	modulesDir = "#{__dirname}/../modules"
	for module in fs.readdirSync modulesDir
		continue unless 'all' in enabled or module in enabled

		moduleDir = "#{modulesDir}/#{module}"
		module = modules[module] = require require.resolve "#{moduleDir}/#{module}"
		module.middleware = {}
		module.identities = {}

		identitiesDir = "#{moduleDir}/identities"
		if fs.existsSync identitiesDir
			for name in fs.readdirSync identitiesDir
				file = fs.readFileSync "#{identitiesDir}/#{name}", 'utf8'
				name = path.basename name, path.extname name
				identities = module.identities[name] = {}
				for line in file.split "\n"
					line = line.split ' '
					device = do line.shift
					line = line.join ' '
					line = do line.trim
					identities[device] = [] unless identities[device]
					identities[device].push line

		middlewareDir = "#{moduleDir}/middleware"
		continue unless fs.existsSync middlewareDir
		for name in fs.readdirSync middlewareDir
			module.middleware[name] = require "#{middlewareDir}/#{name}"

exports.list = ->
	Object.keys exports.modules

exports.amount = ->
	Object.keys(exports.modules).length