root = window

root.BaseController = class BaseController extends root.AutoAttachableDependent
	# $_name: "BaseController" # Your extending BaseController *must* declare its own $_name property to function - this is due to minification

	$_autoAttachToDependency: '$scope' # typically speaking, could also be '$rootScope'

	$_addToAngular: ( module ) ->
		super
		if module?
			module.controller @$_makeName(), @$_makeConstructorArray()
		else
			@$_makeConstructorArray()
