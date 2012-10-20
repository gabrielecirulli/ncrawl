# ncrawl #

Network crawler

## Installation ##

```bash
$ npm install ncrawl
```

or

```bash
$ git clone git@github.com:sebmck/ncrawl.git ncrawl
```

### Examples ###

Scan subnet and display empty scans and failed modules.

```bash
$ ncrawl -T 192.168.2.1-192.168.2.255 --empty --errors
```

### Command Line Options ###

```bash
$ ncrawl --help

  Usage: ncrawl [options]

  Options:

    -h, --help                                output usage information
    -V, --version                             output the version number
    -T, --targets <string>                    List of targets (192.168.2.1-192.168.5.255)
    -e, --errors                              Show errored modules
    -h, --empty                               Show empty targets
    -o, --operations [number]                 Amount of concurrent operations [256]
    -t, --timeout [number]                    Module timeout in milliseconds [2000]
    -r, --reporter [string]                   Reporter to use [default]
    -m, --modules [comma delimetered string]  Only run specified modules [all]

```

## API ##

```coffeescript
ncrawl = require 'ncrawl'
ncrawl
	targets: [] # if a string is given then it goes through a string explode on the comma delimeter and ip ranges are parsed, if an array is given target parsing is bypassed and the array is used instead
	modules: [] # array of modules that are to be ran, if array contains 'all', all other elements are ignored and all are allowed
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
	error: (code, msg) ->
		# code 1 - msg no targets selected - ran when no targets are specified
		# code 2 - msg no modules selected - ran when no modules are specified
	progress: (data) ->
		# ran after each scan or after every progressInterval
		# data.progress - float containing the progress out of 100
		# data.totalScans - number of total scans
		# data.compeltedScans - number of completed scans
		# data.eta - amount of time estimated until completion in milliseconds
		# data.elapsed - amount of time elapsed in milliseconds
	progressInterval: 0 # time in milliseconds that the progress function will be called, if undefined it's called after each scan
	Reporter: class Reporter
		# all of these are optional
		info: (info) ->
			# ran before modules start, after target info has been gathered
			# info.isIP - whether or not the target was given to us as an ip
			# info.hostname - if target was hostname then this value is the target otherwise it's the first dns resolved hostname
			# info.ip - if target was ip then this value is the target otherwise it's the first dns resolved ip
			# info.resolve - an object of all the resolved ips with an array of resolved hostnames for each ip
		identify: (type) ->
			# ran when a piece of middleware detects that the target may be the specified type
			# may be ran more than once depending on results
			# type - expected results are fax, printer, nas, switch, embedded, camera
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
		finish: (info, results, id) ->
			# ran after a scan has been completed with the target info, module results and the scan id
			# info - see @info for details
			# results - object of module results, key is module name, see @result for value details
			# id - scan id
```

## License ##

The MIT License (MIT)
Copyright (c) 2012 Sebastian McKenzie
 
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.