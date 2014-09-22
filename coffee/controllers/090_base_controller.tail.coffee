angoolar.BaseController = class BaseController extends angoolar.AutoAttachableDependent
	# $_name: "BaseController" # Your extending BaseController *must* declare its own $_name property to function - this is due to minification

	$_autoAttachToDependency: '$scope' # typically speaking, could also be '$rootScope'

	$_dependentConstructor: null # this means the actual constructor of this controller class will be used as the final entry in the Angular constructor array.

	$_addToAngular: ( module ) ->
		super
		if module?
			module.controller @$_makeName(), @$_makeConstructorArray()
		else
			@$_makeConstructorArray()
