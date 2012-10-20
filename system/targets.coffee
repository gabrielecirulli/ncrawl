util	= require './util'
net		= require 'net'
_		= require 'underscore'

module.exports = (raw) ->
	targets = []
	for target in raw.split ','
		split = target.split '-'
		if split.length is 2 and net.isIPv4(split[0]) and net.isIPv4 split[1]
			start = util.IPv4ToLong split[0]
			finish = util.IPv4ToLong split[1]
			until start > finish
				targets.push util.longToIPv4 start++
		else
			targets.push target
	_.uniq targets