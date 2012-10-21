fs	= require 'fs'
_s	= require 'underscore.string'
_	= require 'underscore'

protocols =
	tcp: {}
	udp: {}
	sctp: {}
	ddp: {}

byPort = _.clone protocols
byName = _.clone protocols

exports.getByName = (name, type='tcp') ->
	byName[type][name]

exports.getByPort = (port, type='tcp') ->
	byPort[type][port]

filename = switch process.platform
	when 'win32'
		'C:\\WINDOWS\\system32\\drivers\\etc\\services'
	else
		'/etc/services'

file = fs.readFileSync filename, 'utf8'
return unless fs.existsSync filename

for line in file.split "\n"
	line = line.replace /(\s|)#(.*)/, ''

	clean = _s.clean line
	continue unless clean

	match = clean.match /^(\S+)\s(\d+)\/(tcp|udp|sctp|ddp)((\s\S+)+|)$/
	continue unless match

	info =
		name: match[1]
		port: +match[2]
		type: match[3]
		aliases: match[4].trim().split ' '

	byPort[info.type][info.port] = info
	byName[info.type][info.name] = info