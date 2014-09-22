
# For simplicity/coherence, define your directive's controller (if it has one) in the same file as the 
# directive, just before the directive. That way we can easily have all the logic comprising a directive
# in one place (also so we can ensure the directive's controller is declared before the directive, and
# also so we can allow all directives to name their controllers as simply as possible without worrying
# about name collision with other controllers on the angoolar scope).

angoolar.BaseDirectiveController = class BaseDirectiveController extends angoolar.BaseController
	# $_name: "BaseDirectiveController" # This must be overriden in extending directive controllers

	$_dependencies: [ "$element", "$attrs", "$transclude" ]

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
		prefix = @$_prefix or ''
		prefix + if prefix.length is 0 then @$_name.slice( 0, 1 ).toLowerCase() + @$_name.slice 1 else @$_name

	$_dependentConstructor: ->
		directive = new @constructor arguments...
		return directive.$_makeAngularDefinition()

	$_requireSiblings: [] # if this is undefined, the directive won't be able to find its own controller if it's defined; but even if you don't have a controller defined for your directive, this won't cause an error. If you want to inject other controllers, be sure to use an array of the controllers' strings and keep this "?" entry in the first spot
	$_requireParents : []

	$_makeAngularDefinition: ->
		# First prototypally extend the inheritable object properties
		@scope                   = angoolar.prototypallyExtendPropertyObject @, 'scope'                   if @scope?                   and angular.isObject @scope
		@scopeDefaults           = angoolar.prototypallyExtendPropertyObject @, 'scopeDefaults'           if @scopeDefaults?           and angular.isObject @scopeDefaults
		@scopeDefaultExpressions = angoolar.prototypallyExtendPropertyObject @, 'scopeDefaultExpressions' if @scopeDefaultExpressions? and angular.isObject @scopeDefaultExpressions

		# Handle the require properties
		# First, prototypally merge them
		@$_requireSiblings = angoolar.prototypallyMergePropertyArray @, '$_requireSiblings' if @$_requireSiblings? and angular.isArray @$_requireSiblings
		@$_requireParents  = angoolar.prototypallyMergePropertyArray @, '$_requireParents'  if @$_requireParents?  and angular.isArray @$_requireParents

		# Then go through them all, and construct the require property
		if @$_requireSiblings?.length or @$_requireParents?.length
			if @require?
				@require = [ @require ] unless angular.isArray @require
			else
				@require = new Array()

			@require.push sibling: requireDirective for requireDirective in @$_requireSiblings
			@require.push parent : requireDirective for requireDirective in @$_requireParents

			requireStrings = new Array()

			for requireDirective in @require
				if angular.isString requireDirective
					requireStrings.push requireDirective
				else if angular.isObject requireDirective
					if requireDirective.sibling?
						requireStrings.push "?#{ requireDirective.sibling::$_makeName() }"
					else if requireDirective.parent?
						requireStrings.push "^?#{ requireDirective.parent::$_makeName() }"

		definition = {}

		definition.priority    = @priority                                                 if @priority?
		definition.require     = requireStrings or @require                                if requireStrings or @require
		definition.template    = @template                                                 if @template?
		definition.templateUrl = "#{ @templatePath }#{ @templateUrl }#{ @templateSuffix }" if @templateUrl?
		definition.replace     = @replace                                                  if @replace?
		definition.transclude  = @transclude                                               if @transclude?
		definition.restrict    = @restrict                                                 if @restrict?
		definition.scope       = @scope                                                    if @scope?
		definition.controller  = @controller::$_makeConstructorArray()                     if @controller?
		definition.notIsolated = @notIsolated                                              if @notIsolated?

		definition.compile = => 
			@compile arguments...
			{ pre: @preLink, post: @link }

		definition

	$_addToAngular: ( module ) ->
		super

		module.directive @$_makeName(), @$_makeConstructorArray()

	attachController = ( controller, attachTo, requireDirective ) ->
		return unless controller?
		actualName = angoolar.getRequiredDirectiveControllerName( requireDirective.parent or requireDirective.sibling or requireDirective )
		attachTo[ actualName ] = controller if actualName?.length

	# These methods are mostly what you'll want to customize when extending the BaseDirective
	compile: ( tElement, tAttrs, transclude ) => # called only once when the directive's template element is created and modified before cloning.
	preLink: ( scope, iElement, iAttrs, controller ) => # called once for each instance of the directive before each directive's template clone has been linked by the Angular $compile method
		if @require?
			if @controller?::$_name
				directiveController = scope[ @controller?::$_name ]

				if angular.isArray @require
					for requireDirective, i in @require
						attachController controller[ i ], directiveController, requireDirective
				else
					attachController controller, directiveController, @require
			else
				if angular.isArray @require
					for requireDirective, i in @require
						attachController controller[ i ], scope, requireDirective
				else
					attachController controller, scope, @require

	link   : ( scope, iElement, iAttrs, controller ) => # called once for each instance of the directive after its content has been Angular-$compile'd; this is where to do any DOM manipulation specific to each instance of the directive.
		# Set up the defaults for each of the defaults declared for an interpolated isolated scope attribute (by interpolation, we mean '@')
		# See https://groups.google.com/forum/#!msg/angular/3OsaV00UPYs/xJ_tuNru_P4J for an explanation
		angular.forEach @scopeDefaultExpressions, ( defaultExpression, attribute ) => if @scope?[ attribute ]?.charAt() is '@' then iAttrs.$observe attribute, ( value ) => scope.$watch( defaultExpression, ( defaultValue ) -> scope[ attribute ] = defaultValue ) unless angular.isDefined value
		angular.forEach @scopeDefaults          , ( defaultValue     , attribute ) => if @scope?[ attribute ]?.charAt() is '@' then iAttrs.$observe attribute, ( value ) =>                                                      scope[ attribute ] = defaultValue   unless angular.isDefined value

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
	notIsolated: null # This determines whether to treat this directive's scope as isolated or not; if not, then the directive's scope will simply be a child of its parent's scope.

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