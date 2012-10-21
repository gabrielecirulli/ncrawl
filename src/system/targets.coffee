util	= require './util'
net		= require 'net'
_		= require 'underscore'


module.exports = (raw='') ->
	raw = raw.split ',' unless _.isArray targets
	targets = []
	push = (target) ->
		target = do target.trim
		targets.push target if target
	for target in raw
		split = target.split '-'
		if split.length is 2 and net.isIPv4(split[0]) and net.isIPv4 split[1]
			start = util.IPv4ToLong split[0]
			finish = util.IPv4ToLong split[1]
			push util.longToIPv4 start++ until start > finish
		else
			push target
	_.uniq targets