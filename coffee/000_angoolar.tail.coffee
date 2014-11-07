modules           = {} # a hash by $_name (not $_makeName )
targetModuleNames = new Array()

targetModuleIndex = ( module ) ->
	_.indexOf targetModuleNames, module::$_name

angoolar.setTargetModule = ( module ) ->
	targetModuleNames = [ module::$_name ]

angoolar.addTargetModule = ( module ) ->
	targetModuleNames.push module::$_name if -1 is targetModuleIndex module

angoolar.removeTargetModule = ( module ) ->
	targetModuleNames.splice moduleIndex, 1 unless -1 is targetModuleIndex module

angoolar.addModule = ( module, andSetAsTarget = yes ) ->
	modules[ module::$_name ] = new module()
	angoolar.setTargetModule module if andSetAsTarget

angoolar.flushModulesToAngular = ->
	module.$_addToAngular() for moduleName, module of modules
	modules           = {}
	targetModuleNames = new Array()

angoolar.callWithModule = ( callback ) ->
	modules[ targetModuleName ].$_callWithModule callback for targetModuleName in targetModuleNames

# When adding a component, you must specify the component's class/constructor function, and optionally, a target module to specifically add it to (otherwise, all current target modules will receive the new component).
angoolar.addController  = ( controller, targetModule ) -> unless targetModule? then modules[ targetModuleName ].addController  controller for targetModuleName in targetModuleNames else modules[ ( targetModule:: || targetModule ).$_name ].addController  controller
angoolar.addDirective   = ( directive , targetModule ) -> unless targetModule? then modules[ targetModuleName ].addDirective   directive  for targetModuleName in targetModuleNames else modules[ ( targetModule:: || targetModule ).$_name ].addDirective   directive
angoolar.addFactory     = ( factory   , targetModule ) -> unless targetModule? then modules[ targetModuleName ].addFactory     factory    for targetModuleName in targetModuleNames else modules[ ( targetModule:: || targetModule ).$_name ].addFactory     factory
angoolar.addProvider    = ( provider  , targetModule ) -> unless targetModule? then modules[ targetModuleName ].addProvider    provider   for targetModuleName in targetModuleNames else modules[ ( targetModule:: || targetModule ).$_name ].addProvider    provider
angoolar.addFilter      = ( filter    , targetModule ) -> unless targetModule? then modules[ targetModuleName ].addFilter      filter     for targetModuleName in targetModuleNames else modules[ ( targetModule:: || targetModule ).$_name ].addFilter      filter
angoolar.addRunBlock    = ( block     , targetModule ) -> unless targetModule? then modules[ targetModuleName ].addRunBlock    block      for targetModuleName in targetModuleNames else modules[ ( targetModule:: || targetModule ).$_name ].addRunBlock    block
angoolar.addConfigBlock = ( block     , targetModule ) -> unless targetModule? then modules[ targetModuleName ].addConfigBlock block      for targetModuleName in targetModuleNames else modules[ ( targetModule:: || targetModule ).$_name ].addConfigBlock block
angoolar.addAnimation   = ( animation , targetModule ) -> unless targetModule? then modules[ targetModuleName ].addConfigBlock animation  for targetModuleName in targetModuleNames else modules[ ( targetModule:: || targetModule ).$_name ].addAnimation   animation
