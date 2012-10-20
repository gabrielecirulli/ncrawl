module.exports = (identify, data, res, body) ->
	if /(Brother MFC-9450CDN)/i.test data.title
		identify 'fax'