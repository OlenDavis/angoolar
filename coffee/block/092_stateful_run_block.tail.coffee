root = window

root.StatefulRunBlock = class StatefulRunBlock extends root.BaseRunBlock
	
	$_dependencies: [ '$rootScope', '$state', '$stateParams' ]

	constructor: ->
		super

		@$rootScope.$state       = @$state
		@$rootScope.$stateParams = @$stateParams

# root.addRunBlock StatefulRunBlock # This will add the given block to the target module(s)