root = window

root.StatefulConfigBlock = class StatefulConfigBlock extends root.BaseConfigBlock

	$_dependencies: [ '$stateProvider' ]

	templatePath  : root.viewTemplatePath or ''
	templateSuffix: root.staticFileSuffix or ''

	constructor: ->
		super

		@$_states = {}

		@setupStates()

		@applyStates()

	# This should be overridden to call addState for each state being configured in this block of the module.
	setupStates: ->

	applyStates: ->
		@$stateProvider.state stateName, state for stateName, state of @$_states

	# This method wraps adding the state object for the sake of doing some basic error handling, as well as
	# collecting all the unique resolvables out of any controllers defined for the state so you can think about
	# resolvables the way they're actually used - which is most likely on the level of the controller(s) that 
	# would have their resolutions injected into them for processing.
	# 
	# Returns the resulting state object.
	addState: ( stateName, state ) ->
		throw new Error "The state, '#{ stateName }' is already defined for this config block." if _.has @$_states, stateName

		allResolvables = {}

		_.extend allResolvables, state.resolve if state.resolve?

		# Add resolvables declared on the state
		if state.resolvables?.length > 0
			stateResolvables = {}
			resolvable::$_addToAngular stateResolvables for resolvable in state.resolvables
			_.extend allResolvables, stateResolvables

		# Add all resolvables declared on the state's controller
		if state.controller?
			controllerResolvables = {}
			state.controller::$_addResolvablesToAngular?( controllerResolvables )
			_.extend allResolvables, controllerResolvables

			state.controller = state.controller::$_addToAngular()

		# 1) Add all resolvables declared on each views' controller
		# 2) Prepend all defined views' templateUrls with the @templatePath if both are defined
		if state.views?
			for viewName, view of state.views
				if view.controller?
					viewControllerResolvables = {}
					view.controller::$_addResolvablesToAngular?( viewControllerResolvables )
					_.extend allResolvables, viewControllerResolvables

					view.controller = view.controller::$_addToAngular()

				# Prepend the view's templateUrl with the @templatePath if both are defined
				if view.templateUrl?.length > 0
					view.templateUrl = "#{ @templatePath }#{ view.templateUrl }#{ @templateSuffix }" if @templatePath?.length > 0

		state.resolve = allResolvables

		# Prepend the state's templateUrl with the @templatePath if both are defined
		if state.templateUrl?.length > 0
			state.templateUrl = "#{ @templatePath }#{ state.templateUrl }#{ @templateSuffix }" if @templatePath?.length > 0

		@$_states[ stateName ] = state
		state

# root.addConfigBlock StatefulConfigBlock # This will add the given block to the target module(s)	