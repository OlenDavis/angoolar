
angoolar.AutoAttachableDependent = class AutoAttachableDependent extends angoolar.NamedDependent

	$_autoAttachToDependency: null # typically speaking, this would be either '$scope' or '$rootScope', but could really be anything

	$_makeDependencyArray: ->
		super

		if @$_autoAttachToDependency?.length > 0
			( @$_dependencies = _.without @$_dependencies, @$_autoAttachToDependency ).unshift @$_autoAttachToDependency

		# This most simply copies the array (for safety - so any manipulation of the array returned by this doens't affect the class's dependencies).
		@$_dependencies.slice 0 

	constructor: ->
		super

		# If we have an $_autoAttachToDependency defined, then it will necessarily be the first injected dependency, hence the first argument.
		if @$_autoAttachToDependency?.length > 0
			arguments[ 0 ][ @$_name ] = this
