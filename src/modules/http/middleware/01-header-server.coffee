module.exports = (next, data, res) ->
	data.server = res.headers.server if res.headers.server
	do next