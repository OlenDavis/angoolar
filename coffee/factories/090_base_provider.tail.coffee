angoolar.BaseProvider = class BaseProvider extends angoolar.AutoAttachableDependent
	# $_name: 'BaseProvider' # This is commented out because you must declare $_name on your extending provider factory class

	$_factoryDependencies: []

	$_makeName: ->
		@$_prefix + @$_name

	$_addToAngular: ( module ) ->
		super

		@$_factoryDependencies = angoolar.prototypallyMergePropertyArray @, '$_factoryDependencies'
		@$_factoryDependencies.slice 0 # this ensures the dependency array is merely a copy (and adding the return value of makeDependentConstructor to it won't inadvertently add it to the prototypal $_dependencies array)

		constructorArray = @$_getDependencyStringArray @$_factoryDependencies
		constructorArray.push -> 
			# Put our dependencies, which are used by the constructor when creating the instance
			# of the factory service onto the class
			dependencies = arguments
			for dependency, dependencyIndex in @$_factoryDependencies

				# The complexity here allows for the simplicity of being able to declare on your NamedDependent dependencies in $_dependencies that are either
				# strings (as in the case of built-in or imported Angular libraries/modules), or classes (e.g. the class function) extending NamedDependent.
				if angular.isString dependency
					@[ dependency ] = dependencies[ dependencyIndex ]
				else
					@[ dependency::$_name ] = dependencies[ dependencyIndex ] # Note that we attach the instance of the NamedDependent using its $_name, not the return value of its $_makeName - this is because the namespacing provided by $_makeName and $_prefix are for use in markup, not within actual class implementations, which are expected to be internally consistent (of course).
				
			@$_get() # invoke our internal $get() function

		@$get = constructorArray

		module.provider @$_makeName(), @$_makeConstructorArray()


	# The implementation of $get used by the provider.
	# We assign the constructed array to $get, as this is the 'constructor' for
	# the the provider uses to construct the resulting Factory service
	# A user extending BaseProvider would write all their constructor code that
	# would otherwise go into $get in the $_get function.
	$_get: ->
