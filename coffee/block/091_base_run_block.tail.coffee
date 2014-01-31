root = window

root.BaseRunBlock = class BaseRunBlock extends root.BaseBlock
	
	$_dependencies: [ '$rootScope' ]

	constructor: ->
		super

		@$rootScope.isBrowser = root.isBrowser

	$_addToAngular: ( module ) ->
		module.run @$_makeConstructorArray()

# root.addRunBlock BaseRunBlock # This will add the given block to the target module(s)