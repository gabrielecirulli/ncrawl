module.exports = (identify, data, res, body) ->
	if /Camera/i.test data.title
		identify 'camera'