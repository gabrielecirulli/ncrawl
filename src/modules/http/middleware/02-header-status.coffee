module.exports = (next, data, res) ->
	data.status = res.statusCode unless res.statusCode is 200
	do next