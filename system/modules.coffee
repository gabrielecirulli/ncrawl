fs	= require 'fs'
_	= require 'underscore'

exports.modules = {}
exports.run = (enabled=['all']) ->
	enabled = enabled.split ',' if _.isString enabled
	for module in fs.readdirSync 'modules'
		continue unless 'all' in enabled or module in enabled
		exports.modules[module] = require require.resolve "../modules/#{module}/#{module}"
		exports.modules[module].Module::middleware = middleware = {}
		middlewareDir = "modules/#{module}/middleware"
		continue unless fs.existsSync middlewareDir
		for name in fs.readdirSync middlewareDir
			middleware[name] = require "../modules/#{module}/middleware/#{name}"

exports.list = ->
	Object.keys exports.modules

exports.amount = ->
	Object.keys(exports.modules).length