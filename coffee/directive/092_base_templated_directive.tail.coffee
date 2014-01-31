root = window

# The primary value of this class is to automatically set the templateUrl of the directive to that of the name
# of the directive.
root.BaseTemplatedDirective = class BaseTemplatedDirective extends root.BaseDirective
	# $_name: "BaseDirective" # This must be overriden in extending directives

	restrict: 'E'
	replace : yes

	$_makeAngularDefinition: ->
		unless @templateUrl?
			@templateUrl = "#{ root.camelToDashes @$_name }.html"

		super

	compile: ( tElement ) ->
		super

		tElement.addClass root.camelToDashes @$_name