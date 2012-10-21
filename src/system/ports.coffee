_	= require 'underscore'

module.exports = (raw='') ->
	raw = raw.split ',' unless _.isArray raw
	ports = []
	push = (port) ->
		port = do port.trim
		port = +port
		ports.push port if port >= 1 and not isNaN port
	for port in raw
		split = port.split '-'
		if split.length is 2
			start = split[0]
			finish = split[1]
			push start until start > finish
		else
			push port
	_.uniq ports