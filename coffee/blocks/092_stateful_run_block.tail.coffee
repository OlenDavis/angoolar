
angoolar.StatefulRunBlock = class StatefulRunBlock extends angoolar.BaseRunBlock
	
	$_dependencies: [ '$rootScope', '$state', '$stateParams' ]

	constructor: ->
		super

		@$rootScope.$state       = @$state
		@$rootScope.$stateParams = @$stateParams

# angoolar.addRunBlock StatefulRunBlock # This will add the given block to the target module(s)