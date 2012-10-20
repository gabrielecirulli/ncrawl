fs	= require 'fs'
_	= require 'underscore'

exports.modules = {}
exports.run = (enabled=['all']) ->
	enabled = enabled.split ',' if _.isString enabled
	modulesDir = "#{__dirname}/../modules"
	for module in fs.readdirSync modulesDir
		continue unless 'all' in enabled or module in enabled

		moduleDir = "#{modulesDir}/#{module}"
		exports.modules[module] = require require.resolve "#{moduleDir}/#{module}"
		exports.modules[module].Module::middleware = middleware = {}

		middlewareDir = "#{moduleDir}/middleware"
		continue unless fs.existsSync middlewareDir
		for name in fs.readdirSync middlewareDir
			middleware[name] = require "#{middlewareDir}/#{name}"

exports.list = ->
	Object.keys exports.modules

exports.amount = ->
	Object.keys(exports.modules).length