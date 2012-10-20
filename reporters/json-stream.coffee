class JSONStreamReporter
	info: (info) ->
		info.event = 'info'
		console.log JSON.stringify info
	result: (name, result) ->
		result.event = 'result'
		console.log JSON.stringify result

exports.Reporter = JSONStreamReporter

exports.progress = (progress) ->
	console.log JSON.stringify { event: 'progress', progress }