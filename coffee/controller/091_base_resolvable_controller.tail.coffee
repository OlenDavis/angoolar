root = window

root.BaseResolvableController = class BaseResolvableController extends root.BaseController
	# $_name: "BaseResolvableController" # This must be overriden in extending view controllers

	$_dependencies: [ '$stateParams' ]

	$_resolvables: [] # This will hold a hash of BaseResolvable's by their $_makeName()'s

	$_addResolvablesToAngular: ( resolvables ) ->
		@$_resolvables = root.prototypallyMergePropertyArray @, '$_resolvables'

		resolvable::$_addToAngular resolvables for resolvable in @$_resolvables

	$_makeDependencyArray: ->
		super

		@$_resolvables = root.prototypallyMergePropertyArray @, '$_resolvables'

		( @$_dependencies = _.without @$_dependencies, @$_resolvables... ).push @$_resolvables...

		@$_dependencies.slice 0 # This most simply copies the array (for safety - so any manipulation of the array returned by this doens't affect the class's dependencies)

	# For a BaseResolvableController, the usage is to declaratively attach it to a view or state directly.
	# However, we want to still support or ancestor's name checking to support that, so we use $_addToAngular
	# in this case to basically wrap @$_makeConstructorArray.
	$_addToAngular: ->
		super
		@$_makeConstructorArray()