root = window

root.BaseHttpInterceptor = class BaseHttpInterceptor extends root.BaseFactory
	# $_name: 'BaseHttpInterceptor' # This must be overridden in extending interceptors

	$_dependencies: [ '$q', '$injector' ]

	$_hasHttp: no

	# If you just try to inject $http into an interceptor, which is inevitably injected into a config block
	# to be attached to the $httpProvider, then you're already definitely going to be needing to be able to
	# instantiate this factory before $http has even been configured. Therefore, I actually literally override
	# the @$http method as if it were just a method on this factory class, where $http is injected into the 
	# interceptor the first time the method is called. I also remove $http from the interceptors just in case
	# a concientious - but no less naive - developer declares it as a dependency on their interceptor.

	$_makeDependencyArray: ->
		@$_dependencies = super

		@$_hasHttp = _.indexOf( @$_dependencies, '$http' ) >= 0

		@$_dependencies = _.without @$_dependencies, '$http'
		@$_dependencies.slice 0

	injectCircularDependencies: ->
		if @$_hasHttp and not @$http?
			@$http = @$injector.get '$http'



	# This is used to intercept the thus-far successful interception of a request. So for every request, you
	# can specify any number of interceptors in an array attached to the $httpProvider, the order of which is
	# the precendence of the interceptors thusly declared. How these methods works is this: each method must
	# either return the thing it was given, or return a promise object corresponding to some new deferred
	# task your interceptor undertakes given the request or response's intercepted state, upon resolution or
	# rejection of which, the next interceptor (in terms of their precedence in that array) will continue 
	# interception of the request or request response (except in the case of resolution for the interceptor
	# with the highest precedence, after which, the request will actually be made). Note that in the case of
	# request interception, if interception involves returning the promise of a new deferred object, that
	# new deferred object should be resolved with the config object passed into that request interception
	# (or a transformed version of that config object, but it should ultimately be a config object that could
	# be used to perform an $http request, because that's going to be attempted, and if it's not a config
	# object, you'll cause indeterminate behavior that may be a hard-to-debug bug).
	# 
	# Also note that the form of the rejectedResponse can technically be anything, but unless it's the requestResult
	# of an actually javascript error (which should (tm)NEVER happen), it should be an instance of
	# RejectedRequest, that way we have access the config object that caused the rejection. So, when if ever
	# you reject the config intercepting a request, always reject it like so:
	# 	<pre>
	# 		config.reject new root.RejectedRequest config, "I swear something's just plain wrong about this."
	# 	</pre>
	#
	# Also note that the way precedence works with the interceptors is this: the last interceptor in the
	# array - a.k.a. the one at max index - has the highest precedence. Having high precedence as an interceptor
	# means your request method intercepts the config nearest to its request - i.e. earlier interceptors have
	# less interceptors intercepting whatever it chose to do or not do to the config before it turns into an
	# actual async request. Moreover, the interceptor with the highest precedence is also the first to get to
	# intercept the response from its request.
	#
	# Therefore, to add an interceptor without affecting the precedence of existing interceptors (i.e. at the
	# lowest precedence), add it with $httpProvider.interceptors.unshift SomeHttpInterceptor::$_makeName()
	# 
	# Allow me to explain the power of all this. We can have our first, highest precedence interceptor be the
	# one to perform exponential backoff of requests that failed because of device communication issues
	# symptomatic of not having an internet connection and the like, only actually failing the request after
	# the backoffs reach whatever their configured maximum extent (such as binomially increasing retries going
	# from 100 milliseconds to 200, to 400, and so on until the first delay over 5 seconds). And - or I should
	# say AND - the same interceptor can keep track of a globally defined promise that's only defined the first
	# time a request fails due to a connection/communication issue, and resolved the first time a response at
	# least succeeds to communicate (regardless of whether it more semantically succeeded - as can be determined
	# by interceptors of a lower precedence), or rejected when a request fails due to communication/connection
	# issues having been requested after the maximum allowed backoff. The same interceptor can return this
	# 'retrying promise' object from its request method rather than the passed in config whenever the 'retrying
	# promise' is defined, calling then on it with a success callback that returns the passed in config, and
	# returning a new RejectedResponse with the passed in config and a reason of something like "No connection".
	# Moreover, if in the responseError method for this interceptor, it's determined that we're having connection
	# /communication issues, we wouldn't actually return the rejectedResponse or that globally defined promise;
	# we'd create the globally defined promise if it didn't already exist, and regardless of whether it already
	# existed or not, we'd call then on it, and in the resolved callback, we'd simply call $http on the 
	# rejectedResponse's config object again - since we can assume whatever the connection/communication issues
	# we were having are now resolved - and in the rejected callback, we can simply construct and return a 
	# rejectedResponse object capable of describing the fact that we are having connection/communication issues
	# with the failed request.
	#
	# What's so remarkably beautiful about this approach is that the $q-based code to handles *however*
	# recursively complex a data connection/communication exception scenario this frustratingly exception-rich
	# world can throw at it in exactly the same kind of conceptually intuitive way we would handle such
	# communication issues were we doing so physically. Moreover, this can be just the highest priority inter-
	# -ceptor! As the next interceptor, we can do something very similar for handling authentication errors!
	# Note the conceptual congruity: Instead of dealing with delaying and eventually retrying or rejecting 
	# requests due to having a missing or otherwise problematic data connection, an authentication interceptor
	# would do the exact same things but due to not having authentication credentials, or having received the
	# error that means the credentials were wrong (meaning the token expired), and instead of exponentially the
	# same request, it would simply try to authenticate with the cached credentials, retrying the original 
	# request if that re-authentication succeeds or fail if the re-authentication fails, or fail outright if
	# there aren't any cached credentials with which to attempt re-authentication. And note that this second-
	# priority interceptor would work seemlessly with the prior data connectivity interceptor!! Just these two
	# interceptors would replace whole libraries of authentication and generic data-related exception handling
	# code that might still occasionally break in strange use-cases. In other words, using Interceptors 
	# effectively is the QA-wary developer's absolute dream come true!



	# With any of the following methods, always be extremely careful about what you return; for 'request' and
	# 'response' - the positive interceptors - what they ultimately return (i.e. whatever their returned promise
	# can be eventually expected to resolve to) will be used as the config object passed into the $http service,
	# and will only send the interceptors down the negative interception path if what's returned, either
	# immediately or ultimately is wrapped with $q.reject, and if it is, it must be wrapped with the appropriate
	# RejectedResponse or RejectedRequest class - which simply turns into a dependable interface what is a raw
	# object typically created for us by Angular pursuant to even things like Javascript runtime errors.
	# 
	# The point with always returning the corresponding RejectedResponse/RejectedRequest object is that we can
	# actually retry the original request at any point in interception, and, we can actually very concisely
	# encapsulate different kinds of error determinations and actually track what went wrong via the 
	# originalRejectedResponse/originalRejectedRequest members on RejectedResponse/RejectedRequest instances.
	# (And note that a given RejectedResponse/RejectedRequest's original rejection is hooked up for us
	# automatically by passing whatever your current rejectedResponse/rejectedResponse instance is.)



	# P.S. creating a new RejectedResponse or RejectedRequest with an object that is already a RejectedResponse or
	# RejectedRequest won't overwrite the original RejectedResponse/RejectedRequest's reason, but will attach it that
	# original RejectedResponse/RejectedRequest to itself as its originalRejectedResponse/originalRejectedRequest
	# member.


	# In each of the following CALLBACKS - and you must remember to think of them this way - there are only three
	# things you may return from any one of them, one of the three of which is different depending on whether the
	# callback you're returning for is a pre-request callback or a post-request callback:
	#
	# 1: A config/response that will become what descends the positive interception path for the remainder of either
	#    the pre-request interception path, or the post-request interception path. (And note that whether you're
	#    returning this positive config/response from a positive or negative callback in your interception path, it
	#    will determine whether the remainder of that interception path - whether pre or post-request - will be
	#    positive or negative. In other words, you can switch an interception path from negative to positive by 
	#    returning a config/response from requestError or responseError.)
	#
	# 2: A $q.reject wrapped rejection that will become what descends the negative interception path for the
	#    remainder of either the pre or post-request interception path. (Note that just like returning a config or
	#    response from a negative interception callback to switch to a positive interception path, you would return
	#    a @$q.reject wrapped rejection to switch to a negative interception path.)
	#
	# 3: A new PROMISE object, which - and this is of UTMOST IMPORTANCE - will eventually either resolve to a 
	#    config/response (depending on which side of the request your interception callback is on) or a @$q.reject
	#    wrapped rejected request/response (again, depending on which side of the request your interception
	#    callback is on). It's extremely important to drive this home; there are two important points to this:
	#    
	#    A: If you wish to defer the rest of the request's processing/interception (whether that interception is
	#       pre or post-request) you must return a promise, not a deferred, and certainly not null or any other 
	#       object.
	#    
	#    B: The promise returned must *eventually* resolve to something that could otherwise be expected to have been 
	#       returned from the intercepted callback that returned the promise as if it had returned it directly. In
	#       other words, if your interception callback is requestError because the request is missing some essential
	#       part such as an authentication token and you happen to know you have the credentials necessary to get
	#       that authentication token and you therefore wish to make another request to see if you can get it before
	#       then continuing with the request without the error, you could create a deferred and return its promise
	#       and then start a request that would get the new authentication token, and then when the authentication
	#       token request succeeds, you would have to *** resolve the deferred *** whose promise your requestError call-
	#       -back returned earlier *** with the rejectedRequest's config *** not the rejectedRequest and when the 
	#       authentication request fails, *** resolve the deferred *** whose promise your requestError callback 
	#       returned earlier *** with the original rejectedRequest wrapped with @$q.reject ***.



	# This method corresponds to the underlying 'request' interceptor method, but this is the convenient way of
	# handling each of the different use-cases for how you can use an interceptor by making certain assurances for you
	# presuming and enforcing that you follow certain conventions with what you return.
	#
	# Assurances:
	# 1) 'request' will be an instance of root.Request
	#
	# Enforced return-value Conventions:
	# A) To do something without rejecting the request, or to change the request being made, return an instance of
	#    root.Request, whether its the request passed in, or a new instance.
	# B) To reject the request, return an instance of root.RejectedRequest.
	# C) To defer the interception chain against some promise, simply return the promise that will be used to continue
	#    down the interception chain with whatever you resolve or reject your returned promise's deferred object with.
	# D) If you returned the promise of some deferred object, then if you resolve that deferred object, what you
	#    resolve it with must be an instance of root.Request.
	# E) If you returned the promise of some deferred object, then if you rejecte that deferred object, what you
	#    reject it with must be an instance of root.RejectedRequest.
	#
	# If any of those conventions are violated, an error will be thrown immediately, breaking all of the subsequent
	# interceptors - since they'll have null requests/responses as this one will have resulted in null due to throwing
	# an error. This makes it very easy to debug as a huge exception-clamor will have been started as near to the
	# asynchronous source of the problems as conceivably possible.
	interceptRequest: ( request ) -> request

	# This method corresponds to the underlying 'requestError' method and makes similar assurances and enforces similar
	# conventions as the interceptRequest method does:
	#
	# Assurances:
	# 1) 'rejectedRequest' will be an instance of root.RejectedRequest
	#
	# Enforced return-value Conventions:
	# A) To return the interception chain to its non-rejected path, you can return an instance of root.Request.
	# B) To do something while continuing down the rejected path of the interception chain, return the rejectedRequest
	#    passed as an argument, or any other instance of root.RejectedRequest.
	# C) To defer the processing of the remaining interception chain, simply return the promise of a deferred object,
	#    the root.Request or root.RejectedRequest with which you eventually resolve/reject it with will be used to 
	#    continue down the interception chain.
	# D) If you returned the promise of some deferred object, then if you resolve that deferred object, what you
	#    resolve it with must be an instance of root.Request.
	# E) If you returned the promise of some deferred object, then if you rejecte that deferred object, what you
	#    reject it with must be an instance of root.RejectedRequest.
	interceptRejectedRequest: ( rejectedRequest ) -> rejectedRequest

	# This method corresponds to the underlying 'response' method and makes similar assurances and enforces similar
	# conventions as the interceptRequest method does:
	#
	# Assurances:
	# 1) 'response' will be an instance of root.Response
	#
	# Enforced return-value Conventions:
	# A) To do something without rejecting the response, or to change the response being made, return an instance of
	#    root.Response, whether its the response passed in, or a new instance.
	# B) To reject the response, return an instance of root.RejectedResponse.
	# C) To defer the processing of the remaining interception chain, simply return the promise of a deferred object,
	#    the root.Response or root.Response with which you eventually resolve/reject it will be used to continue down
	#    the interception chain.
	# D) If you returned the promise of some deferred object, then if you resolve that deferred object, what you
	#    resolve it with must be an instance of root.Response.
	# E) If you returned the promise of some deferred object, then if you rejecte that deferred object, what you
	#    reject it with must be an instance of root.RejectedResponse.
	interceptResponse: ( response ) -> response

	# This method corresponds to the underlying 'responseError' method and makes similar assurances and enforces similar
	# conventions as the interceptResponse method does:
	#
	# Assurances:
	# 1) 'rejectedResponse' will be an instance of root.RejectedResponse
	#
	# Enforced return-value Conventions:
	# A) To return the interception chain to its non-rejected path, you can return an instance of root.Response.
	# B) To do something while continuing down the rejected path of the interception chain, return the rejectedResponse
	#    passed as an argument, or any other instance of root.RejectedResponse.
	# C) To defer the processing of the remaining interception chain, simply return the promise of a deferred object,
	#    the root.Response or root.RejectedResponse with which you eventually resolve/reject it with will be used to 
	#    continue down the interception chain.
	# D) If you returned the promise of some deferred object, then if you resolve that deferred object, what you
	#    resolve it with must be an instance of root.Response.
	# E) If you returned the promise of some deferred object, then if you rejecte that deferred object, what you
	#    reject it with must be an instance of root.RejectedResponse.
	interceptRejectedResponse: ( rejectedResponse ) -> rejectedResponse



	# *** DON'T OVERRIDE THESE *** The world won't come to an end or anything; they're here to help you - seriously.
	# I don't recommend you override any of the following four methods (request, requestError, response, or
	# responseError) as there are numerous things that can cause errors in your code that will be almost completely
	# impossible to debug, which is why I've written the Request, RejectedRequest, Response, and RejectedResponse
	# objects which should be used entirely as the results of intercept[Rejected]Result and intercept[Rejected]Response
	# unless you're using a nested deferred and returning its promise instead, which should in turn also return a
	# [Rejected]Request or [Rejected]Response. ***

	# Always return one of the following from this method:
	# 1: The [un]modified config argument you were passed
	# 2: A promise for a deferred whose resolution will return the [un]modified config passed into this method,
	#    or, if even that nested promise must return an error, the same as 3:
	# 3: A $q.reject wrapped root.RejectedRequest instance - this is to ensure not only that the return value
	#    registers as an error and doesn't inadvertently allow an erroneous request to be made, but that other
	#    interceptors up the precedence might still be able to complete the original request if possible.
	request: ( config ) => 
		@injectCircularDependencies()
		wrappedRequest = @checkRequest config

		result = @checkRequestResult @interceptRequest( wrappedRequest ), no
		return result

	# Always return one of the following from this method:
	# 1: The [un]modified rejectedRequest argument you were passed
	# 2: If the error can be recovered from, then the original config object contained in the rejectedRequest
	#    (which is only possible if whatever previous - lower priority - interceptor returned a $q.reject wrapped
	#    instance of root.RejectedRequest)
	# 3: A promise for a deferred whose resolution may return the original config in the rejectedRequest, or, if
	#    even that nested promise must return an error, the same as 4:
	# 4: A new $q.reject wrapped root.RejectedRequest instance, referring to the original rejectedRequest
	requestError: ( rejectedRequest ) => 
		@injectCircularDependencies()
		wrappedRejectedRequest = @checkRejectedRequest rejectedRequest

		result = @checkRequestResult @interceptRejectedRequest( wrappedRejectedRequest ), yes
		return result

	# Always return one of the following from this method:
	# 1: The [un]modified response argument you were passed
	# 2: A promise for a deferred whose resolution will return the [un]modified response passed into this method,
	#    or, if even that nested promise must return an error, the same as 3:
	# 3: A $q.reject wrapped root.RejectedResponse instance - this is to ensure not only that the return value
	#    registers as an error and doesn't inadvertently allow an erroneous response to be processed as if it were
	#    valid, but so that other interceptors down the precedence might still be able to intercept the failure as
	#    and perhaps use the original request or just the original response to try and process it successfully, or
	#    start a new request that might be successful
	response: ( response ) => 
		@injectCircularDependencies()
		wrappedResponse = @checkResponse response

		result = @checkResponseResult @interceptResponse( wrappedResponse ), no
		return result

	# Always return one of the following from this method:
	# 1: The [un]modified rejectedResponse argument you were passed
	# 2: If the error can be recovered from, then the original response object contained in the rejectedResponse
	#    (which is only possible if whatever previous - lower priority - interceptor returned a $q.reject wrapped
	#    instance of root.RejectedResponse)
	# 3: A promise for a deferred whose resolution may return the original response in the rejectedResponse, or, if
	#    even that nested promise must return an error, the same as 4:
	# 4: A new $q.reject wrapped root.RejectedResponse instance, referring to the original rejectedResponse
	responseError: ( rejectedResponse ) => 
		@injectCircularDependencies()
		wrappedRejectedResponse = @checkRejectedResponse rejectedResponse

		result = @checkResponseResult @interceptRejectedResponse( wrappedRejectedResponse ), yes
		return result



	# P.P.S. As convention for interceptors, I, Olen Davis, do recommend actually including "return " on each of the
	# the return statements that will immediately or eventually become the next promise in the interception promise
	# chain. As you can see from the CommunicationInterceptor, when encapsulating logic into separate helpers, you
	# can quickly and easily lose track of where and what is actually the immediate and eventual interception promise
	# or config/response. Perish the thought that developers might ignore even one aspect of the gorgeous syntax of
	# Coffeescript, but I find it EXTREMELY helpful as a safeguard against ambiguity in what always ends up being
	# SUCH error-INtolerant code in these interceptors.



	# Takes in whatever was passed into the request callback of the interceptor and ensures that it is at least a raw
	# request object (or 'config', as documented here: http://docs-angularjs-org-dev.appspot.com/api/ng.$http#Usage),
	# and returns an instance of the root.Request class to pass to the interceptRequest method, throwing an immediate
	# and actually helpful error (i.e. one that refers to whatever the prior interceptor was by name - if there was a
	# prior interceptor) if it wasn't a valid request.
	checkRequest: ( request ) ->
		unless root.Request::isWhatItIs request
			errorMessage = "The request intercepted by the '#{ @$_makeName() }' interceptor wasn't actually a request (in JSON):\n\t\t#{ angular.toJson request }"
			errorMessage += "\n(The problem likely originates somewhere in #{ request.$_lastInterceptor }'s interceptRequest method.)" if request.$_lastInterceptor?
			throw new Error errorMessage
		else
			new root.Request request

	# Takes in whatever was passed into the requestError callback of the interceptor and ensures that it is in fact a
	# RejectedRequest, which is actually quite strict. (If you refer to the implementation of root.RejectedRequest::
	# isWhatItIs, you'll see that it checks for an object property that is only attached to the request object - i.e.
	# the 'config' object documented here: http://docs-angularjs-org-dev.appspot.com/api/ng.$http#Usage) So basically
	# this enforces that when using an interceptor that extends BaseHttpInterceptor without totally overriding
	# requestError the only valid way to reject a request is to immediately or eventually return an instance of
	# RejectedRequest. This is for your own good; it allows you to always reject requests (and responses too) with a
	# reason that can be logged, or even potentially in extreme cases displayed in the UI; the method ensures you're
	# adhering to that convention for safety's sake (otherwise, it would be impossible to determine what interceptor
	# was the likely culprit of passing as their result of intercepting a request - or response for that matter - the
	# wrong sort of result).
	checkRejectedRequest: ( rejectedRequest ) ->
		unless root.RejectedRequest::isWhatItIs rejectedRequest
			errorMessage = "The rejectedRequest intercepted by the '#{ @$_makeName() }' interceptor wasn't actually a rejectedRequest (in JSON):\n\t\t#{ angular.toJson rejectedRequest }"
			errorMessage += "\n(The problem likely originates somewhere in #{ rejectedRequest.$_lastInterceptor }'s interceptRejectedRequest method.)" if rejectedRequest.$_lastInterceptor?
			throw new Error errorMessage
		else
			new root.RejectedRequest rejectedRequest

	# Takes in whatever was returned as the result from the interceptor's interceptRequest or interceptRejectedRequest
	# and very strictly enforces that it be either a Request or RejectedRequest. The way we accomplish that, even when
	# the result of the intercept[Rejected]Request is a promise is explained below at the ***PROMISE ENFORCEMENT***
	checkRequestResult: ( requestResult, fromRejection ) ->
		unless ( fromRejection and requestResult instanceof root.RejectedRequest ) or ( not fromRejection and requestResult instanceof root.Request ) or ( @isPromise requestResult )
			throw new Error "The result of the '#{ @$_makeName() }' interceptor's #{ if fromRejection then 'interceptRejectedRequest' else 'interceptRequest' } was not a valid Request, RejectedRequest, or promise object (in JSON):\n\t\t#{ angular.toJson requestResult }"
		else
			unless @isPromise requestResult
				requestResult.setLastInterceptor @, yes

			if requestResult instanceof root.RejectedRequest
				return @$q.reject requestResult
			else if requestResult instanceof root.Request
				return requestResult
			else # requestResult is a promise
				# ***PROMISE ENFORCEMENT***
				# We could of course just return the promise, but that then would allow the promise to eventually be
				# resolved or rejected with something that's not a request. So we simply return the result of our own
				# call to 'then' on the resultant promise within which we call the appropriate checks on the resolved/
				# rejected request, so we can error immediately without passing the erroneously intercepted request
				# along down the interception chain.
				return requestResult.then(
					( ( eventualRequest         ) => @checkRequestResult eventualRequest,         no  )
					( ( eventualRejectedRequest ) => @checkRequestResult eventualRejectedRequest, yes )
				)

	# Just like the checkRequest, this ensures whatever hit this interceptor's 'response' callback is a valid response
	# object, then passes back an instance of the Response class made with it.
	checkResponse: ( response ) ->
		unless root.Response::isWhatItIs response
			errorMessage = "The response intercepted by the '#{ @$_makeName() }' interceptor wasn't actually a response (in JSON):\n\t\t#{ angular.toJson response }"
			errorMessage += "\n(The problem likely originates somewhere in #{ response.$_lastInterceptor }'s interceptResponse method.)" if response.$_lastInterceptor?
			throw new Error errorMessage
		else
			new root.Response response

	# Just like the checkRejectedRequest, this ensures whatever hit this interceptor's 'responseError' callback is
	# either an actual RejectedResponse, OR - and this is unique to the responseError callback - an actual
	# RejectedResponse. Apparently, when $http is given an already rejected (via $q.reject) request, it will pass
	# it through to the response handling directly. Therefore, if we have a RejectedRequest, we'll want to turn it
	# into a RejectedResponse that corresponds to it.
	checkRejectedResponse: ( rejectedResponse ) ->
		unless root.RejectedResponse::isWhatItIs( rejectedResponse ) or rejectedResponse instanceof root.RejectedRequest
			errorMessage = "The rejectedResponse intercepted by the '#{ @$_makeName() }' interceptor wasn't actually a rejectedResponse (in JSON):\n\t\t#{ angular.toJson rejectedResponse }"
			errorMessage += "\n(The problem likely originates somewhere in #{ rejectedResponse.$_lastInterceptor }'s interceptRejectedResponse method.)" if rejectedResponse.$_lastInterceptor?
			throw new Error errorMessage
		else
			unless rejectedResponse instanceof root.RejectedRequest
				new root.RejectedResponse rejectedResponse
			else # if rejectedResponse instanceof root.RejectedRequest
				root.RejectedResponse::fromRejectedRequest rejectedResponse

	# Just like the checkRequestResult, this ensures that what was returned as the result of interceptResponse or
	# interceptRejectedResponse (or eventually be resolved or rejected with) is an instance of Response or
	# RejectedResponse.
	checkResponseResult: ( responseResult, fromRejection ) ->
		unless ( fromRejection and responseResult instanceof root.RejectedResponse ) or ( not fromRejection and responseResult instanceof root.Response ) or ( @isPromise responseResult )
			throw new Error "The result of the '#{ @$_makeName() }' interceptor's #{ if fromRejection then 'interceptRejectedResponse' else 'interceptResponse' } was not a valid Response, RejectedResponse, or promise object (in JSON):\n\t\t#{ angular.toJson responseResult }"
		else
			unless @isPromise responseResult
				responseResult.setLastInterceptor @, yes

			if responseResult instanceof root.RejectedResponse
				return @$q.reject responseResult
			else if responseResult instanceof root.Response
				return responseResult
			else # responseResult is a promise
				# See the ***PROMISE ENFORCEMENT*** comment above in the checkRequestResult for why this is necessary
				# and why/how it works.
				return responseResult.then(
					( ( eventualResponse         ) => @checkResponseResult eventualResponse,         no  )
					( ( eventualRejectedResponse ) => @checkResponseResult eventualRejectedResponse, yes )
				)

	isPromise: ( promise ) ->
		_.isFunction( promise.then )

	isConfig: ( config ) ->
		_.has( config, 'method' ) and _.has( config, 'url' ) and not root.Request::isWhatItIs config

	isRawResponse: ( response ) ->
		_.has( response, 'status' ) and _.has( response, 'config' ) and _.has( response, 'data' ) and _.isFunction response.headers
