class Queue
	constructor: (maxOperations=1) ->
		@currentOperations = 0
		@queue = []
	run: (callback) ->
		return unless callback
		@currentOperations++
		callback =>
			@currentOperations--
			@run do @queue.shift
	add: (callback) ->
		if @currentOperations is @maxOperations
			@queue.push callback
		else
			@run callback

module.exports = Queue