angoolar.BaseComponent = class BaseComponent extends angoolar.Named
	# $_name: "BaseComponent" # Your extending BaseComponent *must* declare its own $_name property to function - this is due to minification

	constructor: ->
		super

		@templateUrl = "#{ @templatePath }#{ @templateUrl }#{ @templateSuffix }" if @templateUrl?
		@controller = @controller::$_makeConstructorArray?() or @controller if @controller?

	$_addToAngular: ( module ) ->
		super

		module.component @$_makeName(), new @constructor()
