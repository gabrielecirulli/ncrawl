{compile}	= require 'coffee-script'
mkdirp		= require 'mkdirp'
{exec}		= require 'child_process'
path		= require 'path'
util		= require './src/system/util'
file		= require 'file'
fs			= require 'fs'

task 'build', 'Build', ->
	util.rmdir 'lib'
	# this is pretty foul, might want to clean it up
	file.walkSync 'src', (dirPath, dirs, files) ->
		return if dirPath is 'src'
		fromDir = dirPath.split(path.sep).slice(1).join path.sep
		toDir = path.join 'lib', fromDir
		fromDir = path.join 'src', fromDir
		mkdirp.sync toDir
		for file in files
			ext = path.extname file
			continue if ext is '.coffee'
			toLoc = path.join toDir, file
			fromLoc = path.join fromDir, file
			content = fs.readFileSync fromLoc, 'utf8'
			fs.writeFileSync toLoc, content, 'utf8'
	exec 'coffee --compile --output lib/ src/', (err, stdout, stderr) ->
		throw err if err
		console.log stdout + stderr