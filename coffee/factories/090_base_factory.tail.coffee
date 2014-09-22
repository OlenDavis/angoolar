
angoolar.BaseFactory = class BaseFactory extends angoolar.AutoAttachableDependent
	# $_name: 'BaseFactory' # This is commented out because you must declare $_name on your extending factory class

	$_dependentConstructor: -> new @constructor arguments...

	$_addToAngular: ( module ) ->
		super
		module.factory @$_makeName(), @$_makeConstructorArray()
