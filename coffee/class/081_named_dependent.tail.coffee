root = window

root.NamedDependent = class NamedDependent extends root.Named
	$_dependencies: []

	constructor: ( dependencies ) ->
		for dependency, dependencyIndex in @$_dependencies

			# The complexity here allows for the simplicity of being able to declare on your NamedDependent dependencies in $_dependencies that are either
			# strings (as in the case of built-in or imported Angular libraries/modules), or classes (e.g. the class function) extending NamedDependent.
			if angular.isString dependency
				@[ dependency ] = dependencies[ dependencyIndex ]
			else
				@[ dependency::$_name ] = dependencies[ dependencyIndex ] # Note that we attach the instance of the NamedDependent using its $_name, not the return value of its $_makeName - this is because the namespacing provided by $_makeName and $_prefix are for use in markup, not within actual class implementations, which are expected to be internally consistent (of course).

	$_getDependencyStringArray: ( dependencies ) ->
		stringDependencies = new Array()
		stringDependencies = for dependency, i in dependencies
			if angular.isString dependency
				dependency
			else
				try
					dependency::$_makeName()
				catch
					throw new Error "The dependency at index #{ i } of #{ @constructor.name }'s $_dependencies cannot be depended upon as its name cannot be made."

		stringDependencies

	$_makeDependencyArray: ->
		@$_dependencies = root.prototypallyMergePropertyArray @, '$_dependencies'

		@$_dependencies.slice 0 # this ensures the dependency array is merely a copy (and adding the return value of makeDependentConstructor to it won't inadvertently add it to the prototypal $_dependencies array)

	$_dependentConstructor: ->
		new @constructor root.argumentsToArray arguments # This will pass all the injected dependencies to the constructor as an array in the first argument

	$_makeConstructorArray: ->
		constructorArray = @$_getDependencyStringArray @$_makeDependencyArray()
		constructorArray.push => @$_dependentConstructor.apply @, arguments

		constructorArray