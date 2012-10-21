module.exports = (data, res) ->
	data.server = res.headers.server if res.headers.server