root = window

root.BaseRequester = class BaseRequester extends root.BaseFactory
	# $_name: 'BaseRequester' # resource requesters extending this class must declare their own names.

	$_dependencies: [ '$resource', '$q', '$timeout', '$injector' ]

	# If $_apiPath is unspecified, it will be constructed from the name of the given resource class:
	# $_resourceClass: root.Resource # This must be defined in your inheritance chain as a class that extends Resource, because it'll be used to construct the resources from responses.

	$_apiScheme: root.defaultScheme
	$_apiDomain: root.apiDomain # ex: 'guru-fam.herokuapp.com'
	# $_apiPath: '/fixed-asset-manager/get-assets/:partnerId/:assetCategoryName'

	# This is a mirror of the actions hash passed into the $resource service as documented here:
	# http://docs.angularjs.org/api/ngResource.$resource#Parameters
	#
	# Pay special attention to the excerpt a little lower on the page that goes something like:
	#	HTTP GET "class" actions: Resource.action([parameters], [success], [error])
	#	non-GET "class" actions: Resource.action([parameters], postData, [success], [error])
	#	non-GET instance actions: instance.$action([parameters], [success], [error])
	# You can ignore the distinction between '"class" actions' vs 'instance actions' because this class actually shields its invoker
	$_actions: {}
	# 	get:
	# 		method: 'GET'

	# 	query:
	# 		method: 'GET' # May be any string in $_allowedActionMethods
	# 		isArray: yes # because this is yes, $_hasArray will be set to yes as well.
	# 		# In all likelihood, there may very well be API endpoints that should be processed as an array, but actually
	# 		# respond with an object that contains the response array somewhere in its fields. In that case, the action
	# 		# would define isArray as no, but $_hasArray as yes with an overriden $_getResponseArray, which would
	# 		# otherwise just parrot the responseData object.
	#		#params: {}
	#		#$_rawResponse: false 
	#		#$_apiPath: 'a/different/path' # Just like you can override the url of the request with a url field on each action, you can override for this helper class, just the $_apiPath for just this action.
	#       #$_attachedOnly: yes # This means this action will only be callable on an instance of the $_resourceClass that has been passed into a call to $_attachRequesterMethods, not directly from the Requester
	# If $_rawResponse is yes, then rather than inferring the type of the response and returning an empty instance of the given
	# $_resourceClass or an empty array of instances of the given $_resourceClass with $_stats, I'll actually return a plain object with $_stats that will be filled in with the object of the eventual response

	# 	put:
	# 		method: 'PUT'

	# 	post:
	# 		method: 'POST'

	# 	delete:
	# 		method: 'DELETE'

	$_actionDefaults: {} # These will be applied to all action definitions

	$_allowedActionMethods: [ 'GET', 'PUT', 'POST', 'DELETE' ]

	# $_actionStats: {} # This will have a Stats instance for each of the $_actions above

	# $_stats: null # This is just like actionStats, but for all actions' requests.

	# A method with the following signature is generated for you by the constructor for each action/key in the class's $_actions hash (including all the
	# @$_actions hashes up the ancestral inheritance tree too).
	#
	# DON'T DECLARE THIS FUNCTION - but even if you do, the constructor will just obliterate it - it'll still be there on the prototype, but it'll
	# be overwritten on each constructed instance so you'll NEVER be able to reach it - unless you also override the constructor without calling
	# super.
	#
	# someCustomAction: ( parameters[, postData if not method 'GET' ], successCallback, errorCallback ) ->

	# Given a declared action 'someCustomAction', you can declare a success and/or error handler by declaring methods like so: (which are both
	# purely optional)
	#
	# someCustomActionSuccess: ( responseResource, headersGetter, parameters, postData ) -> # transform responseResource or do something because of the successful resource response
	# someCustomActionError  : ( rejectedResponse               , parameters, postData ) -> # transform the rejectedResponse or do something because of the erroneous resource response

	isHttpMethod: ( method ) -> -1 isnt _.indexOf @$_allowedActionMethods, method

	constructor: ->
		super

		@$_actionStats = {}

		@$_apiPath = @$_resourceClass::$_makeApiPath() if @$_resourceClass? and not ( @$_apiPath?.length > 0 )

		@$_actionDefaults = root.prototypallyExtendPropertyObject @, '$_actionDefaults'
		@$_actions        = root.prototypallyExtendPropertyObject @, '$_actions'

		notAttachedOnlyActions = {}
		for actionName, actionDefinition of @$_actions
			# Merge the $_actionDefaults into the actionDefinition without overriding its original members or changing its JS reference (if I didn't care about obliterating the actionDefinition reference, I'd just do actionDefinition = angular.extend {}, @$_actionDefaults, actionDefinition)
			actionDefinition = angular.extend {}, @$_actionDefaults, actionDefinition

			# Imply $_hasArray from isArray
			actionDefinition.$_hasArray = actionDefinition.$_hasArray or actionDefinition.isArray or false

			# Setup the url for the action if it has an $_apiPath
			actionDefinition.url = "#{ @$_apiScheme }#{ root.escapeColons @$_apiDomain }#{ actionDefinition.$_apiPath }" if actionDefinition.$_apiPath?.length

			# Initialize each action's stats
			@$_actionStats[ actionName ] = new root.Stats @$injector

			notAttachedOnlyActions[ actionName ] = actionDefinition unless actionDefinition.$_attachedOnly

		# Initialize our cumulative stats
		@$_stats = new root.Stats @$injector

		@resource = @$resource(
			"#{ @$_apiScheme }#{ root.escapeColons @$_apiDomain }#{ @$_apiPath }"
			null
			notAttachedOnlyActions
		)

		_.each notAttachedOnlyActions, ( actionDefinition, actionName ) =>
			@constructor::[ actionName ] = ( parameters, postData, theirSuccess, theirError ) =>
				responseResource = @$_newResponseResource actionDefinition, parameters, postData

				@$_action responseResource, actionDefinition, actionName, parameters, postData, theirSuccess, theirError

	$_newResponseResource: ( actionDefinition = {}, parameters = {}, postData = null ) ->
		if actionDefinition.$_rawResponse
			newResource = @$_initResourceStats if actionDefinition.$_hasArray then new Array() else {}
		else
			unless actionDefinition.$_hasArray
				newResource = new @$_resourceClass()
			else
				newResource = new Array()
				newResource.$_parameters = parameters
				newResource.$_postData   = postData
				# We assign these here because while when calling the $action methods assigned to the resource instance, the query parameters and postData
				# relevant to the $action can be gotten from the resource instance, when calling the same $action methods on an array created by the $_hasArray
				# $action method (originally gotten by calling that $action on the resource requester), we won't be able to get the parameters or post data
				# unless we saved it, which we do here by attaching it to the resource response array we create here.

			@$_attachRequesterMethods newResource


		newResource

	$_initResourceStats: ( resource ) -> # note that resource may be an empty array to be eventually filled with resources that will each have their own stats assigned
		resource.$_actionStats               = resource.$_actionStats               or {}
		resource.$_actionStats[ actionName ] = resource.$_actionStats[ actionName ] or new root.Stats @$injector for actionName in _.keys @$_actions
		resource.$_stats                     = resource.$_stats                     or new root.Stats @$injector

		resource # for method chaining

	# This is called automatically on all resource instances produced by the actions of this requester; however if you want to attach requester methods
	# to a resource instance you make, you can do so by calling this with the instance of your resource.
	$_attachRequesterMethods: ( resourceInstance ) ->
		@$_initResourceStats resourceInstance

		_.each @$_actions, ( actionDefinition, actionName ) =>
		# For each of this requester's actions

			actualAction = @$_action

			resourceInstance[ "$#{ actionName }" ] = ( parameters, postData, theirSuccess, theirError ) ->
				unless actionDefinition.$_hasArray
					parameters = @$_parameters = angular.extend {}, ( actionDefinition.params or {} ), @$_getApiParameters(), parameters
					postData   = @$_postData   = angular.extend {}, ( actionDefinition.data   or {} ), @$_toJson( @ ),           postData unless actionDefinition.method is 'GET'
				else
				# If we're calling this on what might be an array of resources, then arg1 is the parameters, and if the action isn't a GET action, then arg2 is the post data, and the remaining arguments are the success and error callbacks
					parameters = @$_parameters = angular.extend {}, ( actionDefinition.params or {} ), @$_parameters, parameters
					postData   = @$_postData   = angular.extend {}, ( actionDefinition.data   or {} ), @$_postData,   postData unless actionDefinition.method is 'GET'
					theirSuccess = unless actionDefinition.method is 'GET' then theirSuccess else theirError
					theirError   = unless actionDefinition.method is 'GET' then theirError   else theirSuccess

				theirWrappedSuccess = =>
					@[ "$#{ actionName }Success" ]?( arguments... )
					theirSuccess?( arguments... )
				theirWrappedError = =>
					@[ "$#{ actionName }Error" ]?( arguments... )
					theirError?( arguments... )

				actualAction @, actionDefinition, actionName, parameters, postData, theirWrappedSuccess, theirWrappedError

		resourceInstance

	$_action: ( responseResource, actionDefinition, actionName, parameters, postData, theirSuccess, theirError ) =>
		if actionDefinition.method is 'GET'
			theirError   = theirSuccess
			theirSuccess = postData
			postData     = null

		deferred = @$q.defer()
		responseResource.$_promise = deferred.promise

		success = ( responseData, headersGetter ) => @success responseResource, responseData, headersGetter, theirSuccess, theirError, deferred, actionName, actionDefinition, parameters, postData
		error   = ( rejectedResponse            ) => @error   responseResource, rejectedResponse,                          theirError, deferred, actionName, actionDefinition, parameters, postData

		@$_stats                                    .addPending()
		@$_actionStats[ actionName ]                .addPending()
		responseResource.$_stats                    .addPending()
		responseResource.$_actionStats[ actionName ].addPending()

		if actionDefinition.method is 'GET' then @resource[ actionName ] parameters,           success, error
		else                                     @resource[ actionName ] parameters, postData, success, error

		deferred.promise.then(
			( result ) => # resource request resolved
				@$_stats                                    .pendingResolved result
				@$_actionStats[ actionName ]                .pendingResolved result
				responseResource.$_stats                    .pendingResolved result
				responseResource.$_actionStats[ actionName ].pendingResolved result
			( rejection ) => # resource request rejected
				@$_stats                                    .pendingRejected rejection
				@$_actionStats[ actionName ]                .pendingRejected rejection
				responseResource.$_stats                    .pendingRejected rejection
				responseResource.$_actionStats[ actionName ].pendingRejected rejection
		)

		responseResource

	# These two methods shouldn't really be overriden, but certainly can be so long as you call super LAST - i.e. at the end of your method body,
	# NOT first as is typical when overriding methods. Ultimately what they do is take care of resolving/rejecting the request's corresponding deferred
	# promise for you. So long as you do that, feel free. Also, when resolving/rejecting remember that whatever you resolve/reject with will constitute
	# the response of the request.
	# 
	# There's a precedence in the order of invokation on the potential success callbacks that should be observed too: 
	#
	# 1) First, the initial method body of an overriding implemenation of @success( responseData, headersGetter, theirSuccess, deferred, actionName,
	# actionDefinition ) in the class extending this BaseRequester (which better call super).
	# 
	# 2) Second to process the response will then be the parsed success member of this class (the overriding class that is): e.g. in the case of the
	# 'get' action, it would be @getSuccess( responseData, headersGetter ). In the case of an action declared on some overriding Requester
	# called 'getMyStuff', it would be @getMyStuff( responseData, headersGetter ).
	# 
	# 3) Finally, the success callback passed directly into the original invokation of the action. e.g. given an invokation of the 'get' action like
	# @get( parameters, someSuccessCallback, someErrorCallback ), it would be someSuccessCallback( responseData, headersGetter ), which is passed to
	# this method as theirSuccess.
	success: ( responseResource, responseData, headersGetter, theirSuccess, theirError, deferred, actionName, actionDefinition, parameters, postData = null ) => 
		responseData = if actionDefinition.$_hasArray then @$_getResponseArray responseData else @$_getResponseObject responseData

		unless actionDefinition.$_rawResponse
			if actionDefinition.$_hasArray
				newResources = new Array()
				newResources.push @$_makeResponseResource @$_newResponseResource(), responseDatum, parameters for responseDatum in responseData
				@$_mergeIntoResponseResourceArray newResources, responseResource
			else
				@$_makeResponseResource responseResource, responseData, parameters
		else
			angular.extend responseResource, responseData

		@$q       .when( if angular.isFunction @[ "#{ actionName }Success" ] then @[ "#{ actionName }Success" ] responseResource, headersGetter, parameters, postData else null ).then(
			=> @$q.when( if angular.isFunction theirSuccess                  then theirSuccess                  responseResource, headersGetter, parameters, postData else null ).then(
				=> deferred.resolve responseResource # only resolves the request if all the intermediary success callbacks' return values also resolve
			)
			( rejection ) => @error responseResource, rejection, theirError, deferred, actionName, actionDefinition, parameters, postData # and will be handled the same as a rejected request otherwise
		)

	error: ( responseResource, rejectedResponse, theirError, deferred, actionName, actionDefinition, parameters, postData = null ) => 
		if angular.isFunction @[ "#{ actionName }Error" ] then @[ "#{ actionName }Error" ] rejectedResponse, parameters, postData
		if angular.isFunction theirError                  then theirError                  rejectedResponse, parameters, postData
		# The above could be written instead as the following, but it doesn't seem Angular's $resource usage cases use the success/error
		# callbacks to *transform* the rejectedResponse, merely to have access to it when notified of success/error. Nevertheless, this could be a
		# possibility:
		# rejectedResponse = theirError rejectedResponse, headersGetter
		# or even:
		# processedResponseData = theirError rejectedResponse, headersGetter
		# rejectedResponse = processedResponseData if processedResponseData?
			
		deferred.reject rejectedResponse

	$_makeResponseResource: ( responseResource, responseDatum, parameters ) ->
		responseResource.$_setApiParameters( parameters )
		@$_fromJson responseResource, responseDatum

	$_mergeIntoResponseResourceArray: ( newResources, responseResource ) =>
		# # This is pseudocode for the optimization to implement when folks notice that our arrays of resources flash when an API operation concludes.
		# if newResources?[ 0 ]?.id? # if the array has ID'd resources, then intelligently replace them where any corresponding resources already exist in the array
		# 	# construct an object IDs indexed by their corresponding positions in the array with all the ids in the current resources array to remove at the end of all this (any resources in the new resources array will be removed from this hash as we go along replacing them)

		# 	for newResource in newResources
		# 		# if the corresponding resource exists
		# 		# replace it if it does, and remove its ID and position from the object of IDs to remove
		# 		# or add it to an array of resources to add (at the end of all this) if it doesn't

		# 	# in reverse order, remove all the positions left over in the object of IDs to remove
		# 	# then add all the resources to add

		# else # for an array of non-ID'd resources, just replace the array wholesale:
		responseResource.length = 0
		responseResource.push newResources...

	$_getResponseArray: ( responseData ) ->
		responseData

	$_getResponseObject: ( responseData ) ->
		responseData

	$_toJson  : ( resource       ) -> resource.$_toJson()
	$_fromJson: ( resource, json ) -> resource.$_fromJson json
