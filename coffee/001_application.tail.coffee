root = window

root.modules = {}

root.oooooAngularModules = {}

targetModuleNames = new Array()

targetModuleIndex = ( module ) ->
	_.indexOf targetModuleNames, module::$_makeName()

root.setTargetModule = ( module ) ->
	targetModuleNames.push module::$_makeName() if -1 is targetModuleIndex module

root.unsetTargetModule = ( module ) ->
	targetModuleNames.splice moduleIndex, 1 unless -1 is targetModuleIndex module

root.addModule = ( module ) ->
	root.modules[ module::$_makeName() ] = module

root.getTargetModules = () ->
	targetModuleNames

root.addController  = ( controller ) -> root.modules[ targetModule ]::addController  controller for targetModule in targetModuleNames
root.addDirective   = ( directive  ) -> root.modules[ targetModule ]::addDirective   directive  for targetModule in targetModuleNames
root.addFactory     = ( factory    ) -> root.modules[ targetModule ]::addFactory     factory    for targetModule in targetModuleNames
root.addFilter      = ( filter     ) -> root.modules[ targetModule ]::addFilter      filter     for targetModule in targetModuleNames
root.addRunBlock    = ( block      ) -> root.modules[ targetModule ]::addRunBlock    block      for targetModule in targetModuleNames
root.addConfigBlock = ( block      ) -> root.modules[ targetModule ]::addConfigBlock block      for targetModule in targetModuleNames
