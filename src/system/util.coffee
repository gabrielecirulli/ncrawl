exports.IPv4ToLong = (str) ->
	parts = str.split '.'
	parts[0] << 24 | parts[1] << 16 | parts[2] << 8 | parts[3] << 0

exports.longToIPv4 = (l) ->
	((l >> 24) & 255) + '.' + ((l >> 16) & 255) + '.' + ((l >> 8) & 255) + '.' + ((l >> 0) & 255)