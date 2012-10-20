util	= require './util'
net		= require 'net'
_		= require 'underscore'

exports.targets = []

exports.amount = ->
	exports.targets.length

exports.run = (raw='') ->
	targets = []
	push = (target) ->
		target = do target.trim
		targets.push target if target
	for target in raw.split ','
		split = target.split '-'
		if split.length is 2 and net.isIPv4(split[0]) and net.isIPv4 split[1]
			start = util.IPv4ToLong split[0]
			finish = util.IPv4ToLong split[1]
			until start > finish
				push util.longToIPv4 start++
		else
			push target
	exports.targets = _.uniq targets