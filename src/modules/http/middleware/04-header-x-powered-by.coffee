module.exports = (next, data, res) ->
	data['powered by'] = res.headers['x-powered-by'] if res.headers['x-powered-by'] 
	do next