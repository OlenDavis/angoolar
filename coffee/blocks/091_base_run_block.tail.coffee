
angoolar.BaseRunBlock = class BaseRunBlock extends angoolar.BaseBlock
	
	$_dependencies: [ '$rootScope' ]

	constructor: ->
		super

		@$rootScope.isBrowser = angoolar.isBrowser

	$_addToAngular: ( module ) ->
		module.run @$_makeConstructorArray()

# angoolar.addRunBlock BaseRunBlock # This will add the given block to the target module(s)