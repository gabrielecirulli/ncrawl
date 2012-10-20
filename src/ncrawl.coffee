commands	= require './system/commands'
ncrawl		= require './system/ncrawl'

options = do commands.cli
ncrawl options, process.exit if options