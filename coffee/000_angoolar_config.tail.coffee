angoolar.defaultPrefix = '/* @echo prefix */'

angoolar.defaultScheme       = '/* @echo applicationConfig_defaultScheme */'
angoolar.apiDomain           = '/* @echo applicationConfig_apiDomain */'
angoolar.staticFileDomain    = '/* @echo applicationConfig_staticFileDomain */'
angoolar.staticFileDirectory = '/* @echo applicationConfig_staticFileDirectory */'
angoolar.staticFileSuffix    = '/* @echo applicationConfig_staticFileSuffix */'

angoolar.staticFilePath = "#{ angoolar.defaultScheme }#{ angoolar.staticFileDomain }/#{ angoolar.staticFileDirectory }/"

angoolar.directiveTemplatePath = "#{ angoolar.staticFilePath }/* @echo templateDir *///* @echo directiveDir *//" # This allows us to set where the templates for directives are coming from so we can host them not necessarily from the same domain
angoolar.viewTemplatePath      = "#{ angoolar.staticFilePath }/* @echo templateDir *///* @echo viewDir *//" # This allows us to set where the templates for the views corresponding to different states are coming from so we can host them not necessarily from the same domain or just change them all in one place
angoolar.imgPath               = "#{ angoolar.staticFilePath }/* @echo imgDir *//" # this is a hack for now to guarantee that image resources can be loaded from any particular build folder