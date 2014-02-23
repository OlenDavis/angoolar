
angoolar.BaseFilter = class BaseFilter extends angoolar.NamedDependent
	# $_name: 'BaseFilter' # This is commented out because you must declare $_name on your extending filter class

	$_dependentConstructor: ->
		filter = new @constructor angoolar.argumentsToArray arguments # This will pass all the injected dependencies to the constructor as an array in the first argument
		filter.$_filter

	$_addToAngular: ( module ) ->
		super
		module.filter @$_makeName(), @$_makeConstructorArray()

	# This wraps filter, so the user/developer doesn't have to worry about using => rather than ->
	$_filter: =>
		@filter arguments...

	# And this is the one the user/developer should override
	filter: ->