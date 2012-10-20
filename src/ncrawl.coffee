commands	= require './system/commands'
ncrawl		= require './system/ncrawl'

options = do commands.cli
if options
	options.after = ->
		do process.exit
	ncrawl options