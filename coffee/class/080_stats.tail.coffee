root = window

root.Stats = class Stats

	constructor: (
		@$injector # this has to come from whatever scope that might expect to be re-digested when its deferreds are resolved/rejected/notified
	) -> 
		@$q = @$injector.get '$q'
		@$log = @$injector.get '$log'
		@init()

	init: =>

		# This is the always up-to-date count of pending requests.
		@pendingCount = 0

		# This is a promise corresponding to a $q.defer() object that is only created the first time a request is made, and only resolved once all 		# pending requests have been either resolved or rejected. It is therefore never rejected, but instead will ultimately resolve to an object with two keys,
		# resolveCount and rejectCount. It is also notified every time a request is resolved or rejected with whatever the result is - whether resolution or rejection.
		#
		# This is really here for the sake of being able to prevent changing app contexts until all pending requests have not only finished but
		# succeeded, giving the developer the ability to take appropriate actions (by perhaps preventing the user from taking inappropriate actions) only once you
		# have all the information you need - such as knowing that all your pending deletes actually succeeded.
		@pendingResults = @$q.when(
			resolveCount: 0
			rejectCount : 0
		)

		@$includesRejection = no

		# This is really for internal use, but always indicates the current results of all the concurrently processing requests.
		@$_pendingDeferred = null

		# This is for internal use, and is the deferred whose promise is the pendingResults promise.
		@$_currentResults =
			resolveCount: 0
			rejectCount : 0

	addPending: =>
		if 0 is @pendingCount++
		# If this is the first pending stat (incrementing the count regardless), then:

			# Create the deferred and expose its promise
			@$_pendingDeferred = @$q.defer()
			@pendingResults = @$_pendingDeferred.promise

			# And on completion, reset this action's data
			@pendingResults.finally => @init()

	pendingResolved: ( result ) =>
		@$_currentResults.resolveCount++

		@notifyPendingResult result

	pendingRejected: ( rejection ) =>
		@$_currentResults.rejectCount++

		@$includesRejection = yes

		@notifyPendingResult @$q.reject rejection

	notifyPendingResult: ( result ) =>
		@pendingCount--

		if @pendingCount < 0
			@pendingCount = 0
			@$log.warn "There was an unmatched pending resolved or rejected. You must call pendingResolved or pendingRejected only once for each call to addPending. The easiest way for this to happen is for a JS error to prevent the call to pendingResolved or pendingRejected from being made."

		@$_pendingDeferred?.notify result 

		# If this was the last pending action, decrementing the count regardless
		if 0 is @pendingCount
			if @$includesRejection
				@$_pendingDeferred?.reject @$_currentResults
			else
				@$_pendingDeferred?.resolve result

			@$includesRejection = no

		result # for method chaining