angoolar.BaseModule = class BaseModule extends angoolar.Named
	# $_name: "BaseModule" # Extending modules must declare their own names

	configBlocks: new Array() # These must extend BaseConfigBlock, and if defined, will each be instantiated upon module config
	runBlocks   : new Array() # These must extend BaseRunBlock,    and if defined, will each be instantiated upon module run
	factories   : new Array() # These must extend BaseFactory,     and if defined, will each be attached to the created module
	filters     : new Array() # These must extend BaseFilter,      and if defined, will each be attached to the created module
	directives  : new Array() # These must extend BaseDirective,   and if defined, will each be attached to the created module
	controllers : new Array() # These must extend BaseController,  and if defined, will each be attached to the created module
	animations  : new Array() # These must extend BaseAnimation,   and if defined, will each be attached to the created module

	addConfigBlock: ( configBlock ) -> unless @$_module? then @configBlocks.push configBlock else configBlock::$_addToAngular @$_module
	addRunBlock   : ( runBlock    ) -> unless @$_module? then @runBlocks   .push runBlock    else runBlock   ::$_addToAngular @$_module
	addFactory    : ( factory     ) -> unless @$_module? then @factories   .push factory     else factory    ::$_addToAngular @$_module
	addFilter     : ( filter      ) -> unless @$_module? then @filters     .push filter      else filter     ::$_addToAngular @$_module
	addDirective  : ( directive   ) -> unless @$_module? then @directives  .push directive   else directive  ::$_addToAngular @$_module
	addController : ( controller  ) -> unless @$_module? then @controllers .push controller  else controller ::$_addToAngular @$_module
	addAnimation  : ( animation   ) -> unless @$_module? then @animations  .push animation   else animation  ::$_addToAngular @$_module

	$_dependencies: [ 'ng' ]

	constructor: ->
		super
		@$_callbacks = new Array()

	$_addToAngular: ->
		super
		
		@$_dependencies = angoolar.prototypallyMergePropertyArray @, '$_dependencies'

		@$_module = angular.module( @$_makeName(), @$_dependencies )

		configBlock::$_addToAngular @$_module for configBlock in @configBlocks
		runBlock   ::$_addToAngular @$_module for runBlock    in @runBlocks
		factory    ::$_addToAngular @$_module for factory     in @factories
		filter     ::$_addToAngular @$_module for filter      in @filters
		directive  ::$_addToAngular @$_module for directive   in @directives
		controller ::$_addToAngular @$_module for controller  in @controllers
		animation  ::$_addToAngular @$_module for animation   in @animations

		@$_callWithModule()

		@$_module

	$_callWithModule: ( callback ) ->
		@$_callbacks.push callback if angular.isFunction callback
		if @$_module
			callback @$_module for callback in @$_callbacks
			@$_callbacks = new Array()

# angoolar.addModule       BaseModule # This is how to add the module to Angular
# angoolar.setTargetModule BaseModule # This is how to set this module to be the target module to which angoolar.addDirective and angoolar.addController's directives/controllers will be added
