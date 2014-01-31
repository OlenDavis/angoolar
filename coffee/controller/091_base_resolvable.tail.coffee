root = window

root.BaseResolvable = class BaseResolvable extends root.NamedDependent
	# $_name: "BaseResolvable" # This must be declared in an extending resolvable to be able to be declared on a BaseState or BaseResolvableController

	# This should either return a value that represents the resolution of this resolvable, or this
	# should return a promise, which when resolved, represents the resolution of this, either of
	# which, will be passed into any BaseResolvableController that depends on the resolution of this.
	# 
	# So for instance, if the state declared a resolvable of this one's $_makeName(), then any of its
	# views' controllers could depend on this resolvable's $_makeName() and receive whatever object
	# this method returns attached to itself (along with the rest of its dependencies). Moreover, a
	# BaseResolvableController could declare this Resolvable, and any BaseState to which its BaseView is part
	# of will inherit the resolvable and ensure that it is resolved before transitioning to the state
	# (and of course injecting this resolvable's resolution among its other dependencies).
	resolve: -> null # by default, the resolvable resolves to null

	$_dependentConstructor: ->
		resolvable = super
		resolvable.resolve() # We return whatever the resolvable should resolve to (as opposed to a BaseController's $_dependentConstructor, which returns the controller)

	$_addToAngular: ( resolvables ) ->
		super
		resolvables[ @$_makeName() ] = @$_makeConstructorArray()

# Any resolvables corresponding to a given BaseState or BaseResolvableController should either be declared and 
# attributed to that BaseState or BaseResolvableController in the same file - just like the BaseDirectiveController
# is in the same file as its corresponding BaseDirective.