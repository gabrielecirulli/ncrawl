class JSONReporter
	finish: (info, results, id) ->
		console.log JSON.stringify { info, results, id, event: 'results' }

exports.Reporter = JSONReporter