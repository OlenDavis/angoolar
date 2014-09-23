
angoolar.BaseModule = class BaseModule extends angoolar.Named
	# $_name: "BaseModule" # Extending modules must declare their own names

	configBlocks: new Array() # These must extend BaseConfigBlock, and if defined, will each be instantiated upon module config
	runBlocks   : new Array() # These must extend BaseRunBlock,    and if defined, will each be instantiated upon module run
	factories   : new Array() # These must extend BaseFactory,     and if defined, will each be attached to the created module
	providers   : new Array() # These must extend BaseProvider,    and if defined, will each be attached to the created module
	filters     : new Array() # These must extend BaseFilter,      and if defined, will each be attached to the created module
	directives  : new Array() # These must extend BaseDirective,   and if defined, will each be attached to the created module
	controllers : new Array() # These must extend BaseController,  and if defined, will each be attached to the created module
	animations  : new Array() # These must extend BaseAnimation,   and if defined, will each be attached to the created module

	addProvider   : ( provider    ) -> @providers   .push provider
	addConfigBlock: ( configBlock ) -> @configBlocks.push configBlock
	addRunBlock   : ( runBlock    ) -> @runBlocks   .push runBlock
	addFactory    : ( factory     ) -> @factories   .push factory
	addFilter     : ( filter      ) -> @filters     .push filter
	addDirective  : ( directive   ) -> @directives  .push directive
	addController : ( controller  ) -> @controllers .push controller
	addAnimation  : ( animation   ) -> @animations  .push animation

	$_dependencies: [ 'ng' ]

	$_addToAngular: ->
		super

		@$_dependencies = angoolar.prototypallyMergePropertyArray @, '$_dependencies'

		module = angular.module( @$_makeName(), @$_dependencies )

		provider   ::$_addToAngular module for provider    in @providers
		configBlock::$_addToAngular module for configBlock in @configBlocks
		runBlock   ::$_addToAngular module for runBlock    in @runBlocks
		factory    ::$_addToAngular module for factory     in @factories
		filter     ::$_addToAngular module for filter      in @filters
		directive  ::$_addToAngular module for directive   in @directives
		controller ::$_addToAngular module for controller  in @controllers
		animation  ::$_addToAngular module for animation   in @animations

		module

# angoolar.addModule       BaseModule # This is how to add the module to Angular
# angoolar.setTargetModule BaseModule # This is how to set this module to be the target module to which angoolar.addDirective and angoolar.addController's directives/controllers will be added
