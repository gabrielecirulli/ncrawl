class JSONReporter
	finish: (id, info, results) ->
		console.log JSON.stringify { info, results, id, event: 'results' }

exports.Reporter = JSONReporter