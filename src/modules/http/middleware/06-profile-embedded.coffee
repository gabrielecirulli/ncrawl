module.exports = (identify, data, res, body) ->
	if /(Allegro-Software-RomPager|GoAhead-Webs|Netgem)/i.test data.server
		identify 'embedded'