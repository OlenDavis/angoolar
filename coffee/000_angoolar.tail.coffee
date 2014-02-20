angoolar.modules = {} # a hash by $_name (not $_makeName )

targetModuleNames = new Array()

targetModuleIndex = ( moduleConstructor ) ->
	_.indexOf targetModuleNames, moduleConstructor::$_name

angoolar.setTargetModule = ( moduleConstructor ) ->
	targetModuleNames.push moduleConstructor::$_name if -1 is targetModuleIndex moduleConstructor

angoolar.unsetTargetModule = ( moduleConstructor ) ->
	targetModuleNames.splice moduleIndex, 1 unless -1 is targetModuleIndex moduleConstructor

angoolar.addModule = ( moduleConstructor, andSetAsTarget = yes ) ->
	angoolar.modules[ moduleConstructor::$_name ] = new moduleConstructor()
	angoolar.setTargetModule moduleConstructor if andSetAsTarget

# When adding a component, you must specify the component's class/constructor function, and optionally, a target module to specifically add it to (otherwise, all current target modules will receive the new component).
angoolar.addController  = ( controllerConstructor, targetModule ) -> unless targetModule? then angoolar.modules[ targetModuleName ].addController  controllerConstructor for targetModuleName in targetModuleNames else angoolar.modules[ ( targetModule:: || targetModule ).$_name ].addController  controllerConstructor
angoolar.addDirective   = ( directiveConstructor , targetModule ) -> unless targetModule? then angoolar.modules[ targetModuleName ].addDirective   directiveConstructor  for targetModuleName in targetModuleNames else angoolar.modules[ ( targetModule:: || targetModule ).$_name ].addDirective   directiveConstructor
angoolar.addFactory     = ( factoryConstructor   , targetModule ) -> unless targetModule? then angoolar.modules[ targetModuleName ].addFactory     factoryConstructor    for targetModuleName in targetModuleNames else angoolar.modules[ ( targetModule:: || targetModule ).$_name ].addFactory     factoryConstructor
angoolar.addFilter      = ( filterConstructor    , targetModule ) -> unless targetModule? then angoolar.modules[ targetModuleName ].addFilter      filterConstructor     for targetModuleName in targetModuleNames else angoolar.modules[ ( targetModule:: || targetModule ).$_name ].addFilter      filterConstructor
angoolar.addRunBlock    = ( blockConstructor     , targetModule ) -> unless targetModule? then angoolar.modules[ targetModuleName ].addRunBlock    blockConstructor      for targetModuleName in targetModuleNames else angoolar.modules[ ( targetModule:: || targetModule ).$_name ].addRunBlock    blockConstructor
angoolar.addConfigBlock = ( blockConstructor     , targetModule ) -> unless targetModule? then angoolar.modules[ targetModuleName ].addConfigBlock blockConstructor      for targetModuleName in targetModuleNames else angoolar.modules[ ( targetModule:: || targetModule ).$_name ].addConfigBlock blockConstructor
