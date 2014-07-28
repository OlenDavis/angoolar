angoolar.BaseNestedTranscludeDirective = class BaseNestedTranscludeDirective extends angoolar.BaseDirective

	$_nestedTranscludeOf: null # this must be overridden with the directive to be used as the parent transcluding directive to transclude here

	$_makeAngularDefinition: ->
		if @$_nestedTranscludeOf?
			@$_requireParents.push @$_nestedTranscludeOf
			@controller::$_nestedTranscludeOfController = angoolar.getRequiredDirectiveControllerName @$_nestedTranscludeOf
		else
			throw new Error "A $_nestedTranscludeOf must be declared on a directive extending BaseNestedTranscludeDirective to function correctly."

		super

	controller: class BaseNestedTranscludeDirectiveController extends angoolar.BaseDirectiveController
		$_name: 'BaseNestedTranscludeDirectiveController'

		$_link: ->
			super

			@[ @$_nestedTranscludeOfController ].$transclude ( $contents ) =>
				@$element.append $contents
