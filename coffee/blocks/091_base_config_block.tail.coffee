
angoolar.BaseConfigBlock = class BaseConfigBlock extends angoolar.BaseBlock

	$_dependencies: [ '$httpProvider' ]

	constructor: ->
		super
		
		@setupInterceptors()

	# TODO: Update this comment to reflect the simplification of removing the setupBaseInterceptors method.
	# This should be overridden to add any interceptors to the httpProvider when the BaseConfigBlock is never 
	# going to be overridden (which would then cause all of the interceptors added in here to be added
	# for this config block as well as each config block inheriting from this one).
	setupInterceptors: ->

	# This adds the given interceptor to the $httpProvider's interceptors at the lowest-yet precedence. The
	# 'interceptor' argument may be a class extending BaseHttpInterceptor, or what that class's $_makeName
	# would return.
	#
	# FYI, it is impossible for an interceptor added with addLowestPrecedenceInterceptor to be of a higher
	# precedence than an interceptor added with addHighestPrecedenceInterceptor. Moreover, an interceptor
	# added with addLowestPrecedenceInterceptor after another interceptor added with the same will always
	# be of lower precedence than the prior.
	addLowestPrecedenceInterceptor: ( interceptor ) ->
		@$httpProvider.interceptors.unshift if angular.isString( interceptor ) then interceptor else interceptor?::$_makeName?()

	# This adds the given interceptor to the $httpProvider's interceptors at the highest-yet precedence. The
	# 'interceptor' argument may be a class extending BaseHttpInterceptor, or what that class's $_makeName
	# would return.
	#
	# FYI, it is impossible for an interceptor added with addHighestPrecedenceInterceptor to be of a lower
	# precedence than an interceptor added with addLowestPrecedenceInterceptor. Moreover, an interceptor
	# added with addHighestPrecedenceInterceptor after another interceptor added with the same will always
	# be of higher precedence than the prior.
	addHighestPrecedenceInterceptor: ( interceptor ) ->
		@$httpProvider.interceptors.push if angular.isString( interceptor ) then interceptor else interceptor?::$_makeName?()

	$_addToAngular: ( module ) ->
		super
		module.config @$_makeConstructorArray()

	# Override the building of the dependency array, so that we can inject our own custom
	# providers. These dependencies are injected by simply adding 'Provider' to the end of
	# the string returned by $_makeName()
	$_getDependencyStringArray: ( dependencies ) ->
		super

		stringDependencies = new Array()
		stringDependencies = for dependency, i in dependencies
			if angular.isString dependency
				dependency
			else
				try
					dependency::$_makeName().concat 'Provider'
				catch
					throw new Error "The dependency at index #{ i } of #{ @constructor.name }'s $_dependencies cannot be depended upon as its name cannot be made."

		stringDependencies

# angoolar.addConfigBlock BaseConfigBlock # This will add the given block to the target module(s)