module.exports = (identify, data, res, body) ->
	if /(Allegro-Software-RomPager|GoAhead-Webs)/i.test data.server
		identify 'embedded'