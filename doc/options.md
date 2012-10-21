# Options #

## Targets `-T, --targets`, `targets` ##

```coffeescript
ncrawl = require 'ncrawl'
ncrawl
	targets: [] # if a string is given then it goes through a string explode on the comma delimeter and ip ranges are parsed, if an array is given target parsing is bypassed and the array is used instead
	addTarget: # internal function, accepts a target and an optional completion callback that is called with the same arguments as Reporter.finish
	# the following are ALL optional
	ports: [] # an array or comma delimetered strings with ranges of additional ports you'd like scanned
	modules: [] # array or comma delimetered string of modules that are to be ran, if array contains 'all', all other elements are ignored and all are allowed
	before: ->
		# ran before all scans are ran
		# data.totalModules - total modules that are going to be ran
		# data.totalTargets - total targets that are going to be scanned
	after: (data) ->
		# expected result is scan statistics or a banner, cleanup etc
		# ran after all scans are ran
		# data.start - start local time in milliseconds
		# data.finish - start finish time in milliseconds
		# data.took - total time taken in milliseconds
	queue: (id, target) ->
		# ran after a scan is queued
		# id - scan id
		# target - parsed target id
	error: (code, msg) ->
		# code 1 - msg no targets selected - ran when no targets are specified
		# code 2 - msg no modules and/or ports selected
	progress: (data) ->
		# ran after each scan or after every progressInterval
		# data.progress - float containing the progress out of 100
		# data.totalScans - number of total scans
		# data.compeltedScans - number of completed scans
		# data.remainingScans - number of remaining scans
		# data.eta - amount of time estimated until completion in milliseconds
		# data.elapsed - amount of time elapsed in milliseconds
	progressInterval: 0 # time in milliseconds that the progress function will be called, if undefined it's called after each scan
	info: ->
		# arguments same as Reporter.info
	identify: ->
		# arguments same as Reporter.identify
	result: ->
		# arguments same as Reporter.result
	start: ->
		# arguments same as Reporter.start
	finish: ->
		# arguments same as Reporter.finish
	Reporter: class Reporter # reporter, keeping scan state
		info: (info) ->
			# ran before modules start, after target info has been gathered
			# info.isIP - whether or not the target was given to us as an ip
			# info.hostname - if target was hostname then this value is the target otherwise it's the first dns resolved hostname
			# info.ip - if target was ip then this value is the target otherwise it's the first dns resolved ip
			# info.resolve - an object of all the resolved ips with an array of resolved hostnames for each ip
			# info.mx - an array of mail exchange servers if a hostname was found, array contains objects with exchange, and priority
			# info.txt - an array of text queries if a hostname was found
			# info.srv - an array of service records if a hostname was found, array contains objects with weight, port, and name
			# info.ns - an array of name servers if a hostname was found
			# info.cname - an array of canonical name records if a hostname was found
		identify: (data) ->
			# ran when a piece of middleware detects that the target may be the specified device
			# may be ran more than once depending on results
			# data.device - expected results are fax, printer, nas, switch, embedded, camera
			# data.id - scan id
		result: (module, result) ->
			# ran after a module has completed
			# module - name of module
			# result.error - set if the module failed to connect
			# result.port - port the module tried to connect to
			# result.start - start local time in milliseconds
			# result.finish - start finish time in milliseconds
			# result.took - total time taken in milliseconds
			# result.module - name of module
			# result.id - scan id
			# result.data - an object of data that the module middleware picked up
		start: (id, target) ->
			# ran after the scan has been taken out of the queue and started
			# id - scan id
			# target - parsed target id
		finish: (id, info, results) ->
			# ran after a scan has been completed with the target info, module results and the scan id
			# info - see Reporter.info for details
			# results - object of module results, key is module name, see Reporter.result for details
			# id - scan id
```