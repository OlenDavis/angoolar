angoolar.moduleConstructors = {}

angoolar.modules = {}

targetModuleNames = new Array()

targetModuleIndex = ( module ) ->
	_.indexOf targetModuleNames, module::$_makeName()

angoolar.setTargetModule = ( module ) ->
	targetModuleNames.push module::$_makeName() if -1 is targetModuleIndex module

angoolar.unsetTargetModule = ( module ) ->
	targetModuleNames.splice moduleIndex, 1 unless -1 is targetModuleIndex module

angoolar.addModule = ( module ) ->
	angoolar.moduleConstructors[ module::$_makeName() ] = module

angoolar.getTargetModules = () ->
	targetModuleNames

angoolar.addController  = ( controller ) -> angoolar.moduleConstructors[ targetModule ]::addController  controller for targetModule in targetModuleNames
angoolar.addDirective   = ( directive  ) -> angoolar.moduleConstructors[ targetModule ]::addDirective   directive  for targetModule in targetModuleNames
angoolar.addFactory     = ( factory    ) -> angoolar.moduleConstructors[ targetModule ]::addFactory     factory    for targetModule in targetModuleNames
angoolar.addFilter      = ( filter     ) -> angoolar.moduleConstructors[ targetModule ]::addFilter      filter     for targetModule in targetModuleNames
angoolar.addRunBlock    = ( block      ) -> angoolar.moduleConstructors[ targetModule ]::addRunBlock    block      for targetModule in targetModuleNames
angoolar.addConfigBlock = ( block      ) -> angoolar.moduleConstructors[ targetModule ]::addConfigBlock block      for targetModule in targetModuleNames
