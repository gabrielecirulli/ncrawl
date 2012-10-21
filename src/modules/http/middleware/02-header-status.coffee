module.exports = (data, res) ->
	data.status = res.statusCode unless res.statusCode is 200