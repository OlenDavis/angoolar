root = window

root.BaseResource = class BaseResource extends root.Named
	$_prefix: '' # by default, we don't want to prefix our resource names
	$_makeName: ->
		@$_checkName()
		root.camelToDashes super # dasherize the name of the resource

	$_idProperty: null # If defined, automatically appends the specified property underscored as the last path segment of the API path made for this resource (e.g. /:id), and adds the given property to $_properties as '=@'

	$_makeApiPath: ->
		apiPath = "/#{ @$_makeName() }"
		apiPath += "/:#{ root.camelToUnderscores @$_idProperty }" if @$_idProperty?.length

		apiPath

	# This object's keys correspond to this object's properties/members, and its values correspond to the corresponding
	# keys in any JSON object being parsed from or to this object.
	# $_propertyToJsonMapping: {}
	# 	property: 'corresponding_json_property'
	# 	etc     : 'corresponding_json_etc'
	$_propertyToJsonMapping: {}

	# This object's keys correspond to this object's properties/members, and its values correspond to the corresponding
	# API parameters in the $_apiPath of any class extending BaseRequester class that lists this class extending
	# BaseResource. For instance for a BaseRequester::$_apiPath of "something/:correspondingApiParameter/etc/:apiEtc"
	# the following would be a valid $_propertyToApiMapping:
	# $_propertyToApiMapping: {}
	# 	property: 'correspondingApiParameter'
	# 	etc     : 'apiEtc'
	$_propertyToApiMapping: {}

	# This allows for a completely consistent treatment of all properties and how they are serialized/deserialized. To include
	# a property to be serialized/deserialized, simply include its field name in this object as a key, with a value of one of:
	#	*	'='                           - the property will be serialized into and deserialized from JSON
	#	*	'@'                           - the property will be used as a parameter for all requests
	#	*	'=@'                          - both = and @
	#	*	function extends BaseResource - the property will be serialized into and deserialized from JSON as an instance of the
	#		                                given resource
	$_properties: {}

	# This allows us to have properties of the resource be instances of other resources. The following is an example using
	# all possible parameters on each resource property. The key of each property of $_propertyToResourceMapping is the property
	# of this resource that will be populated with an instance or an array of instances of the resource class given by each
	# each corresponding resourceClass, which must be a class extending BaseResource.
	#
	# (If the jsonExpression refers to a property that's an array, it will loop through each object in the array and add an
	# instance of the given resourceClass for each.)
	# $_propertyToResourceMapping:
	# 	assets: # our property name
	# 		assets: # the json property name
	# 			root.Asset # the BaseResource-extending class used to make an instance for each (if an array) object in the json property
	#		weirdAssets:
	#			root.WeirdAsset
	$_propertyToResourceMapping: {}
	# As an aside for future development, I would like to see this work with the $_propertyToApiMapping member to actually 
	# allow the propertyToApiMapping object contain all the property references, but this to determine whether those references
	# are simple (or just what their JSON representations are) or class instances, given by this member. And maybe that would
	# be better suited by a different member that ecompasses both declarations in one BaseResource property.

	# By setting this to yes, then the JSON expressions can use `this` and have it refer to the JSON object itself.
	# You should set this to `no` if you know that your JSON responses will have a field called `this` as it would
	# be overriden by the self reference if `$_useThis` is `yes`.
	$_useThis: yes

	constructor: ->
		unless @constructor::hasOwnProperty( '$_propertiesConfigured' ) and @constructor::$_propertiesConfigured
			@constructor::$parse = angular.injector( [ 'ng' ] ).get "$parse"

			@constructor::$_properties                = root.prototypallyExtendPropertyObject @, '$_properties'
			@constructor::$_propertyToJsonMapping     = root.prototypallyExtendPropertyObject @, '$_propertyToJsonMapping'
			@constructor::$_propertyToApiMapping      = root.prototypallyExtendPropertyObject @, '$_propertyToApiMapping'
			@constructor::$_propertyToResourceMapping = root.prototypallyExtendPropertyObject @, '$_propertyToResourceMapping'
			@constructor::$_allProperties             = _.union(
				_.keys @constructor::$_properties
				_.keys @constructor::$_propertyToJsonMapping
				_.keys @constructor::$_propertyToApiMapping
				_.keys @constructor::$_propertyToResourceMapping
			)

			if @$_idProperty?.length and not @$_properties[ @$_idProperty ]?
				@constructor::$_properties[ @$_idProperty ] = '=@'

			for property, propertyUsage of @$_properties
				underscorizedProperty = root.camelToUnderscores property

				if angular.isString propertyUsage
					inJson = -1 isnt propertyUsage.indexOf '='
					inApi  = -1 isnt propertyUsage.indexOf '@'

					@constructor::$_propertyToJsonMapping[ property ] = underscorizedProperty if inJson
					@constructor::$_propertyToApiMapping[  property ] = underscorizedProperty if inApi

				else if angular.isFunction propertyUsage
					resourceMapping = {}
					resourceMapping[ underscorizedProperty ] = propertyUsage

					@constructor::$_propertyToResourceMapping[ property ] = resourceMapping

			@constructor::$_propertiesConfigured = yes

		@$_init()

	# Copies all requestable properties not excluded in excludeProperties to this resource from anotherResource
	copy: ( anotherResource, excludeProperties = {} ) =>
		for field in @$_allProperties
			unless excludeProperties[ field ]
				@[ field ] = angular.copy anotherResource[ field ]

	# This method is used to initialize the resource after it's been created - i.e. including the constructor and JSON deserialization
	$_init: ->

	$_toJson: ->
		json = {}

		json.this = json if @$_useThis

		# Actually assign all the JSON properties properly to the resource if possible
		angular.forEach @$_propertyToJsonMapping, ( jsonExpression, propertyExpression ) =>
			propertyExpressionGetter = @$parse propertyExpression
			jsonExpressionSetter = @$parse( jsonExpression ).assign
			jsonExpressionSetter json, propertyExpressionGetter @

		# Assign all the aggregated resources
		angular.forEach @$_propertyToResourceMapping, ( aggregateResourceDefinition, propertyExpression ) =>
			propertyExpressionGetter = @$parse propertyExpression

			angular.forEach aggregateResourceDefinition, ( resourceClass, jsonExpression ) =>
				jsonExpressionSetter = @$parse( jsonExpression ).assign

				jsonAggregateResources = new Array()
				isPropertyArray = no

				aggregatedResourceObjectOrArray = propertyExpressionGetter @
				return unless angular.isDefined aggregatedResourceObjectOrArray

				if aggregatedResourceObjectOrArray instanceof resourceClass
				# If the property is an instance of the given resource
					jsonAggregateResources.push aggregatedResourceObjectOrArray.$_toJson()

				else if angular.isArray aggregatedResourceObjectOrArray
				# If the property is an array of instances of the given resource class
					isPropertyArray = yes

					for aggregatedResource in aggregatedResourceObjectOrArray
						jsonAggregateResources.push aggregatedResource.$_toJson() if aggregatedResource instanceof resourceClass

				else if angular.isObject( aggregatedResourceObjectOrArray )
				# If the property is actually a hash of the given resource
					isPropertyArray = yes

					for aggregatedResource of aggregatedResourceObjectOrArray
						jsonAggregateResources.push aggregatedResource.$_toJson() if aggregatedResource instanceof resourceClass

				if isPropertyArray or jsonAggregateResources.length > 1
					jsonExpressionSetter json, jsonAggregateResources
				else
					jsonExpressionSetter json, jsonAggregateResources[ 0 ] if jsonAggregateResources[ 0 ]?

		root.delete json, 'this' if @$_useThis

		json

	$_fromJson: ( json ) ->
		json = json or {} # ensures if json is null that any errors that may/should arise from that situation occur

		json.this = json if @$_useThis # this is to allow expressions to use `this` to refer to the json object itself

		# Actually assign all the JSON properties properly to the resource if possible
		angular.forEach @$_propertyToJsonMapping, ( jsonExpression, propertyExpression ) =>
			jsonExpressionGetter = @$parse jsonExpression
			jsonValue = jsonExpressionGetter json

			propertyExpressionGetter = @$parse propertyExpression
			propertyExpressionSetter = propertyExpressionGetter.assign
			propertyExpressionSetter @, jsonValue

		# Assign all the aggregated resources
		angular.forEach @$_propertyToResourceMapping, ( aggregateResourceDefinition, propertyExpression ) =>
			# We will first assume we're not going to be attributing these aggregated resources to the given propertyExpression evaluation as an array unless (1), any
			# of the aggregated resources (given by its corresponding jsonExpression) is an array, or (2), we have multiple aggregated resources
			# that each correspond to this same propertyExpression evaluation.
			isPropertyArray = no
			jsonResources = new Array()

			propertyExpressionGetter = @$parse propertyExpression
			propertyExpressionSetter = propertyExpressionGetter.assign

			angular.forEach aggregateResourceDefinition, ( resourceClass, jsonExpression ) =>
				jsonExpressionGetter = @$parse jsonExpression
				jsonResourceObjectOrArray = jsonExpressionGetter json

				if angular.isArray jsonResourceObjectOrArray
					isPropertyArray = isPropertyArray or yes
					jsonResources.push new resourceClass().$_fromJson( jsonResourceDatum ) for jsonResourceDatum in jsonResourceObjectOrArray
				else
					jsonResources.push new resourceClass().$_fromJson( jsonResourceObjectOrArray )

			if isPropertyArray or jsonResources.length > 1
				propertyExpressionSetter @, jsonResources
			else
				propertyExpressionSetter @, jsonResources[ 0 ] if jsonResources[ 0 ]?

		root.delete json, 'this' if @$_useThis

		@$_init()

		@ # for method chaining

	# If there's a resource requester extending BaseRequester that declares this class as its $_resourceClass, then for each of the non-GET
	# actions it declares, there can be two corresponding methods on each instance of this class returned by its various actions according to the
	# following rule:
	# For successful post-processing of the action: $actionSuccess( resourceResponse, headersGetter ) ->
	# For erroneous post-processing of the action: $actionError( resourceResponse, headersGetter ) ->

	$_getApiParameters: ->
		parameters = {}

		for property, apiParameter of @$_propertyToApiMapping
			parameters[ apiParameter ] = @[ property ] if @[ property ]?

		parameters

	$_setApiParameters: ( parameters ) ->
		for property, apiParameter of @$_propertyToApiMapping
			@[ property ] = parameters[ apiParameter ] if parameters?[ apiParameter ]?

		@ # for method chaining