currentOperations = 0
maxOperations = 0

queue = []

run = (callback) ->
	return unless callback
	currentOperations++
	callback ->
		currentOperations--
		run do queue.shift

exports.maxOperations = (operations) ->
	maxOperations = operations

exports.add = (callback) ->
	if currentOperations is maxOperations
		queue.push callback
	else
		run callback