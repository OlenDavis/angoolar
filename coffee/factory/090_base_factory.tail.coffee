root = window

root.BaseFactory = class BaseFactory extends root.AutoAttachableDependent
	# $_name: 'BaseFactory' # This is commented out because you must declare $_name on your extending factory class

	$_addToAngular: ( module ) ->
		super
		module.factory @$_makeName(), @$_makeConstructorArray()
