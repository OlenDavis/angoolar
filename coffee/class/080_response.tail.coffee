root = window 

root.Response = class Response

	constructor: ( response, comment ) ->
		# This allows us to create a Response (or by extension, RejectedResponse) from a Request or RejectedRequest or config object.
		if response instanceof root.Request or root.Request::isWhatItIs( response ) or root.RejectedRequest::isWhatItIs response
			response =
				data   : ''
				status : 0
				headers: -> # this is a sort of null function because the headers for a Request/RejectedRequest don't exist
				config : response

		angular.extend @, response

		# @data – {string|Object} – The response body transformed with the transform functions.
		# @status – {number} – HTTP status code of the response.
		# @headers – {function([headerName])} – Header getter function.
		# @config – {Object} – The configuration object that was used to generate the request.

		@request = new root.Request @request or @config

		@$_lastInterceptor               = @request.$_lastInterceptor or "(None yet)"
		@$_lastInterceptionWasPreRequest = @request.$_lastInterceptionWasPreRequest
		@$_commentCount                  = @request.$_commentCount

		@addComment comment if comment?

	addComment: ( response, comment ) ->
		unless comment?
			comment = response
			response = @

		root.Request::addComment response.request, comment

	getComment: ( response ) ->
		response = response or @

		root.Request::getComment response.request

	getDescription: ( response ) ->
		response = response or @

		comment = @getComment()
		description = "#{ response.config.method }: #{ response.config.url }\tStatus: #{ response.status }\tData: #{ angular.toJson response.data }"
		description += "\tLast intercepted by: #{ response.$_lastInterceptor }" if response.$_lastInterceptor?.length > 0
		description += "\tWith comments (#{ response.$_commentCount }):\n\t#{ comment }" if comment.length > 0
		description

	setLastInterceptor: ->
		@request.setLastInterceptor arguments...

	isWhatItIs: ( possibleResponse ) ->
		( not   possibleResponse  .$_rejected? or
		  not   possibleResponse  .$_rejected      ) and
		( _.has possibleResponse, 'data'           ) and
		        possibleResponse  .status?           and
		( _.has possibleResponse, 'status'         ) and 
		        possibleResponse  .headers?          and
		( _.has possibleResponse, 'headers'        ) and 
		        possibleResponse  .config?           and
		( _.has possibleResponse, 'config'         )
