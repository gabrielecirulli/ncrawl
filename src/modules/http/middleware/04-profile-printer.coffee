module.exports = (identify, data, res, body) ->
	if /(LaserJet|Hewlett Packard|DocuPrint|DocuCentre|Web Image Monitor|Lexmark)/i.test data.title
		identify 'printer'
	if /(KM-MFP-http)/i.test data.server
		identify 'printer'