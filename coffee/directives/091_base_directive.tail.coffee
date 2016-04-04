
# For simplicity/coherence, define your directive's controller (if it has one) in the same file as the 
# directive, just before the directive. That way we can easily have all the logic comprising a directive
# in one place (also so we can ensure the directive's controller is declared before the directive, and
# also so we can allow all directives to name their controllers as simply as possible without worrying
# about name collision with other controllers on the angoolar scope).

angoolar.BaseDirectiveController = class BaseDirectiveController extends angoolar.BaseController
	# $_name: "BaseDirectiveController" # This must be overriden in extending directive controllers

	$_dependencies: [ '$element', '$attrs', '$transclude' ]

	# This is called when the directive has been linked; it's sort of a constructor-type method that's called once any setup in the directive's link function has taken place.
	$_link: ->

# NOTE: While normal controllers must be added to a module to be accessed from that module's scope, a 
# directive's controller merely needs to be prototypally assigned to its directive's class.

angoolar.BaseDirective = class BaseDirective extends angoolar.NamedDependent
	# $_name: "BaseDirective" # This must be overriden in extending directives

	$_dependencies: [ '$parse', '$interpolate' ]

	# Only custom directives' names in markup must be formatted "camelCase", not "CamelCase", so the 
	# $_makeName function has to be modified from the simple concatenation of controllers' prefixing
	# to enforce that all custom directives follow this standard (otherwise, Angular might silently do
	# nothing about our directives).
	$_makeName: ->
		name = super
		name.slice( 0, 1 ).toLowerCase() + name.slice 1

	$_dependentConstructor: ->
		directive = new @constructor arguments...
		return directive.$_makeAngularDefinition()

	$_definitionProperties: [
		'priority'
		'template'
		'templateNamespace'
		'replace'
		'transclude'
		'restrict'
		'scope'
		'require'
		'controllerAs'
		'bindToController'
	]

	$_makeAngularDefinition: ->
		# First prototypally extend the inheritable object properties
		@scope                   = angoolar.prototypallyExtendPropertyObject @, 'scope'                   if @scope?                   and angular.isObject @scope
		@scopeDefaults           = angoolar.prototypallyExtendPropertyObject @, 'scopeDefaults'           if @scopeDefaults?           and angular.isObject @scopeDefaults
		@scopeDefaultExpressions = angoolar.prototypallyExtendPropertyObject @, 'scopeDefaultExpressions' if @scopeDefaultExpressions? and angular.isObject @scopeDefaultExpressions

		if angular.isArray @require
			@require = angoolar.prototypallyMergePropertyArray @, 'require'
		else if angular.isObject @require
			@require = angoolar.prototypallyExtendPropertyObject @, 'require'

		@$_definitionProperties = angoolar.prototypallyMergePropertyArray @, '$_definitionProperties'

		definition = {}

		definition[ property ] = @[ property ] for property in @$_definitionProperties when @[ property ]?

		definition.templateUrl = "#{ @templatePath }#{ @templateUrl }#{ @templateSuffix }" if @templateUrl?
		definition.controller  = @controller::$_makeConstructorArray?() or @controller     if @controller?
		definition.compile = @$_compile

		definition

	$_compile: =>
		@compile.apply @, arguments
		{ pre: @preLink, post: @link }

	$_addToAngular: ( module ) ->
		super

		module.directive @$_makeName(), @$_makeConstructorArray()

	# These methods are mostly what you'll want to customize when extending the BaseDirective
	compile: ( tElement, tAttrs, transclude ) => # called only once when the directive's template element is created and modified before cloning.
	preLink: ( scope, iElement, iAttrs, controller ) => # called once for each instance of the directive before each directive's template clone has been linked by the Angular $compile method
		if @require
			if @controller?::$_name
				attachTo = scope[ @controller?::$_name ]
			else
				attachTo = scope
			
			if angular.isString @require
				controllerName = controller?.$_name or @require
				attachTo[ controllerName ] = controller
			else if angular.isArray @require
				for eachController, index in controller
					controllerName = eachController?.$_name or @require[ index ]
					attachTo[ controllerName ] = eachController
			else if angular.isObject @require
				for controllerName, eachController of controller
					attachTo[ controllerName ] = eachController

	link: ( scope, iElement, iAttrs, controller ) => # called once for each instance of the directive after its content has been Angular-$compile'd; this is where to do any DOM manipulation specific to each instance of the directive.
		# Set up the defaults for each of the defaults declared for any non-& isolated scope attribute (so interpolated, @ or two-way bound, =)
		# See https://groups.google.com/forum/#!msg/angular/3OsaV00UPYs/xJ_tuNru_P4J for an explanation
		angular.forEach @scopeDefaultExpressions, ( defaultExpression, scopeAttribute ) =>
			attribute = @scope?[ attribute ]?.match( /[@=]\??(\w*)/ )?[ 1 ] or scopeAttribute
			if @scope?[ scopeAttribute ]?.charAt( 0 ) isnt '&' and not iAttrs[ attribute ]
				scope.$watch defaultExpression, ( defaultValue ) -> scope[ scopeAttribute ] = defaultValue

		angular.forEach @scopeDefaults, ( defaultValue, scopeAttribute ) =>
			attribute = @scope?[ attribute ]?.match( /[@=]\??(\w*)/ )?[ 1 ] or scopeAttribute
			if @scope?[ scopeAttribute ]?.charAt( 0 ) isnt '&' and not iAttrs[ attribute ]
				scope[ scopeAttribute ] = defaultValue

		# for convenience in not having to setup a watch just to do some basic controller-driven initialization of the directive instance, here we call the $_link method on the controller inheriting BaseDirectiveController
		scope[ @controller?::$_name ]?.$_link?()

	# To use a controller for logic in the directive, attach its constructor here
	controller: null # must be a class that extends BaseDirectiveController

	# See http://docs.angularjs.org/guide/directive for a full description of all these properties of a directive's definition object
	priority   : null
	require    : null
	template   : null
	templateUrl: null
	replace    : null # can also be yes
	transclude : null # by default, this is false, which means the contents of the directive can't be placed into the directive template; if you do want to "transclude" (a.k.a. "put") the directive's inner text into its template, make this true and put the directive, "ng-transclude" on the element you want to receive this directive's inner text
	restrict   : null # by default, this is 'A' for attribute, but can also be 'E' for elements this isn't the Angular default (which is 'A' for attribute) but we will usually use directives for elements (there is also 'M' for comment/meta directives)
	scope      : null # by default, this is false, which this means the directive's scope is not isolated from its parent scope; make it an object with keys for specific bindings on a scope isolated to this directive

	# Use these to specify default values for isolated scope attributes by specifying an object whose keys are the isolate
	# scope attribute names (as given on the scope member), and whose values will define the scope attribute whenever it
	# changes to something undefined (according to angular.isDefined). You can declare the default value one of two ways:
	scopeDefaults          : {} # values are just strings or objects or whatever, and will be set to the scope attribute whenever it is undefined (according to angular.isDefined)
	scopeDefaultExpressions: {} # values are only strings that will be evaluated as angular expressions in the directive's current scope to get the value of the scope attribute whenever it is undefined (according to angular.isDefined)
	# NOTE: when declaring the same key in scopeDefaults and scopeDefaultExpressions, behavior, while not undefined, shouldn't be depended on; the scopeDefaultExpressions watchers will be attached before the watchers for the scopeDefaults, however given the fact that the order of watcher listeners' firing may or may not change, the fact that scopeDefaultExpressions generally have precedence over scopeDefaults, that is really an assumption that's not to be relied upon

	# This allows us to not only set the template directory on a site-by-site basis, but to actually 
	# override it on a directive-by-directive basis.
	# 
	# Btw, the logic for whether or not to use the "template" or "templateUrl" is left entirely up to 
	# Angular. That said, the @templateUrl will always be prepended with @templatePath (so 
	# @templatePath should include a trailing slash).
	templatePath  : angoolar.directiveTemplatePath or ""
	templateSuffix: angoolar.staticFileSuffix or ""

# angoolar.addDirective BaseDirective # This is how to export a directive to the current target module's scope