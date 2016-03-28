angoolar.BaseComponent = class BaseComponent extends angoolar.Named
	# $_name: "BaseComponent" # Your extending BaseComponent *must* declare its own $_name property to function - this is due to minification

	# Reuses the directives' template path/suffix because directives are able to be element-restricted so their names can already conflict
	templatePath  : angoolar.directiveTemplatePath or ""
	templateSuffix: angoolar.staticFileSuffix or ""

	$_addClass: yes

	constructor: ->
		super

		unless @templateUrl?
			@templateUrl = "#{ angoolar.camelToDashes @$_name }.html"

		@templateUrl = "#{ @templatePath }#{ @templateUrl }#{ @templateSuffix }" if @templateUrl?
		@controller = @controller::$_makeConstructorArray?() or @controller if @controller?

	$_addToAngular: ( module ) ->
		super

		module.component @$_makeName(), new @constructor()
