module.exports = (data, res, body) ->
	data.title = match[1] if match = body.match(/<title>\s*((.|\n)*?)\s*<\/title>/i)