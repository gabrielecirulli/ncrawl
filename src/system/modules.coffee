path	= require 'path'
fs		= require 'fs'
_		= require 'underscore'

module.exports = (enabled=['all']) ->
	enabled = enabled.split ',' if _.isString enabled
	modulesDir = "#{__dirname}/../modules"
	modules = {}
	for module in fs.readdirSync modulesDir
		do (module) ->
			return unless 'all' in enabled or module in enabled
			moduleDir = "#{modulesDir}/#{module}"
			module = modules[module] = require require.resolve "#{moduleDir}/#{module}"
			module.middleware = []
			module.identities = {}

			module.runMiddleware = (args..., finished) ->
				middleware = _.clone module.middleware
				data = {}
				next = ->
					fn = do middleware.shift
					return finished { data } unless fn
					fn.apply null, args
				args.unshift data
				args.unshift next
				do next

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
			return unless fs.existsSync middlewareDir
			for name in fs.readdirSync middlewareDir
				module.middleware.push require "#{middlewareDir}/#{name}"
	modules