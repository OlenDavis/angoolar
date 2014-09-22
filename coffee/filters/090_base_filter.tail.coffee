
angoolar.BaseFilter = class BaseFilter extends angoolar.NamedDependent
	# $_name: 'BaseFilter' # This is commented out because you must declare $_name on your extending filter class

	$_dependentConstructor: ->
		filter = new @constructor arguments...
		filter.$_filter

	$_addToAngular: ( module ) ->
		super
		module.filter @$_makeName(), @$_makeConstructorArray()

	# This wraps filter, so the user/developer doesn't have to worry about using => rather than ->
	$_filter: => @filter arguments...

	# And this is the one the user/developer should override
	filter: ->