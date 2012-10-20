log = (obj) ->
	console.log JSON.stringify obj

class JSONStreamReporter
	info: (info) ->
		info.event = 'info'
		log info
	identify: (data) ->
		data.event = 'identify'
		log data
	result: (name, result) ->
		result.event = 'result'
		log result

exports.Reporter = JSONStreamReporter

exports.progress = (data) ->
	data.event = 'progress'
	log data