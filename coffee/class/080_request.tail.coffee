
angoolar.Request = class Request
	type:
		get   : 0
		post  : 1
		put   : 2
		delete: 3
	method:
		get   : 'GET'
		post  : 'POST'
		put   : 'PUT'
		delete: 'DELETE'

	$_maxLeadingCommentCount  : 3 # how many of the FIRST comments attached to the request
	$_maxTrailingCommentCount : 3 # how many of the LATEST comments attached to the request
	$_defaultAllowedRerequests: 10

	constructor: ( request, comment ) ->
		angular.extend @, request

		# @method            {string} – HTTP method (e.g. 'GET', 'POST', etc)
		# @url               {string} – Absolute or relative URL of the resource that is being requested.
		# @params            {Object.<string|Object>} – Map of strings or objects which will be turned to ?key1=value1&key2=value2 after the url. If the value is not a string, it will be JSONified.
		# @data              {string|Object} – Data to be sent as the request message data.
		# @headers           {Object} – Map of strings representing HTTP headers to send to the server.
		# @transformRequest  {function(data, headersGetter)|Array.<function(data, headersGetter)>} – transform function or an array of such functions. The transform function takes the http request body and headers and returns its transformed (typically serialized) version.
		# @transformResponse {function(data, headersGetter)|Array.<function(data, headersGetter)>} – transform function or an array of such functions. The transform function takes the http response body and headers and returns its transformed (typically deserialized) version.
		# @cache             {boolean|Cache} – If true, a default $http cache will be used to cache the GET request, otherwise if a cache instance built with $cacheFactory, this cache will be used for caching.
		# @timeout           {number} – timeout in milliseconds.
		# @withCredentials   {boolean} - whether to to set the withCredentials flag on the XHR object. See requests with credentials for more information.
		# @responseType      {string} - see requestType.

		@$_rejected = no
		@$_creationTime    = @$_creationTime    or new Date().getTime()
		@$_comments        = @$_comments        or new Array()
		@$_commentCount    = @$_commentCount    or 0
		@$_lastCommentTime = @$_lastCommentTime or -1

		@$_lastInterceptor               =    @$_lastInterceptor or "(None yet)"
		@$_lastInterceptionWasPreRequest = if @$_lastInterceptionWasPreRequest? then @$_lastInterceptionWasPreRequest else yes

		@allowedRerequests = @allowedRerequests or @$_defaultAllowedRerequests
		@$_rerequestCount  = @$_rerequestCount  or 0

		@addComment comment if comment?

	mayBeRerequested: ->
		( @allowedRerequests < 0 ) or @$_rerequestCount <= @allowedRerequests

	makeRerequest: ( request, comment ) ->
		request.$_rerequestCount++
		new @constructor request, comment

	addComment: ( request, comment ) ->
		unless comment?
			comment = request
			request = @

		request.$_commentCount++

		now = new Date().getTime()
		comment = "(#{ now - request.$_lastCommentTime } ms later)\t#{ comment }" if request.$_lastCommentTime > 0
		request.$_comments.unshift comment
		request.$_lastCommentTime = now

		if ( not ( request.$_maxLeadingCommentCount < 0 and request.$_maxTrailingCommentCount ) ) and request.$_comments.length > Request::$_maxLeadingCommentCount
			commentsToRemove = request.$_comments.length - ( Request::$_maxLeadingCommentCount + Request::$_maxTrailingCommentCount )
			request.$_comments.splice Request::$_maxLeadingCommentCount, commentsToRemove
			actualCommentsMissing = request.$_commentCount - ( Request::$_maxLeadingCommentCount + Request::$_maxTrailingCommentCount )
			request.$_comments.splice Request::$_maxLeadingCommentCount, 0, "(Removed #{ actualCommentsMissing })" if actualCommentsMissing > 0

	getComment: ( request ) ->
		request = request or @

		request.$_comments.join "\n\t<- "

	getDescription: ( request ) ->
		request = request or @

		comment = @getComment request
		description = "#{ request.method }: #{ request.url }"
		description += "\tWith comments (#{ request.$_commentCount }):\n\t#{ comment }" if comment.length > 0
		description

	# The argument config can be either a config object as passed directly to $http, or an instance of Request.
	isSameRequest: ( request, otherRequest ) ->
		unless otherRequest?
			otherRequest = request
			request = @

		return angular.equals( request.url,          otherRequest.url          ) and
			angular.equals(    request.method,       otherRequest.method       ) and
			angular.equals(    request.params,       otherRequest.params       ) and
			angular.equals(    request.data,         otherRequest.data         ) and
			angular.equals(    request.responseType, otherRequest.responseType )

	getAge: ( request ) ->
		request = request or @

		new Date().getTime() - request.$_creationTime

	setLastInterceptor: ( interceptor, wasPreRequest ) ->
		@$_lastInterceptor               = interceptor.$_makeName()
		@$_lastInterceptionWasPreRequest = wasPreRequest

	isWhatItIs: ( possibleRequest ) ->
		( not   possibleRequest  .$_rejected? or
		  not   possibleRequest  .$_rejected         ) and
		        possibleRequest  .method?              and
		( _.has possibleRequest, 'method'            ) and
		        possibleRequest  .url?                 and
		( _.has possibleRequest, 'url'               ) #and
		#         possibleRequest  .params?              and
		# ( _.has possibleRequest, 'params'            ) and
		#         possibleRequest  .data?                and
		# ( _.has possibleRequest, 'data'              ) and
		#         possibleRequest  .headers?             and
		# ( _.has possibleRequest, 'headers'           ) and
		#         possibleRequest  .transformRequest?    and
		# ( _.has possibleRequest, 'transformRequest'  ) and
		#         possibleRequest  .transformResponse?   and
		# ( _.has possibleRequest, 'transformResponse' ) and
		#         possibleRequest  .cache?               and
		# ( _.has possibleRequest, 'cache'             ) and
		#         possibleRequest  .timeout?             and
		# ( _.has possibleRequest, 'timeout'           ) and
		#         possibleRequest  .withCredentials?     and
		# ( _.has possibleRequest, 'withCredentials'   ) and
		#         possibleRequest  .responseType?        and
		# ( _.has possibleRequest, 'responseType'      )
