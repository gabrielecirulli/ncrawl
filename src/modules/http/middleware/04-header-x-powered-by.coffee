module.exports = (data, res) ->
	data['powered by'] = res.headers['x-powered-by'] if res.headers['x-powered-by'] 