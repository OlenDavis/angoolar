angoolar.NamedDependent = class NamedDependent extends angoolar.Named
	$_dependencies: []

	$_attachDependencies: yes

	constructor: ->
		if @$_attachDependencies
			for dependency, dependencyIndex in arguments
				@[ dependency.$_name or @$_dependencies[ dependencyIndex ] ] = dependency

	$_getDependencyStringArray: ( dependencies ) ->
		stringDependencies = new Array()
		stringDependencies = for dependency, i in dependencies
			if angular.isString dependency
				dependency
			else
				try
					dependency::$_makeName()
				catch
					throw new Error "The dependency at index #{ i } of #{ @constructor.name }'s $_dependencies cannot be depended upon as its name cannot be made: #{ dependency.toString() }"

		stringDependencies

	$_makeDependencyArray: ->
		@$_dependencies = angoolar.prototypallyMergePropertyArray @, '$_dependencies'

		@$_dependencies.slice 0 # this ensures the dependency array is merely a copy (and adding the return value of makeDependentConstructor to it won't inadvertently add it to the prototypal $_dependencies array)

	$_dependentConstructor: @constructor

	$_makeConstructorArray: ->
		constructorArray = @$_getDependencyStringArray @$_makeDependencyArray()
		constructorArray.push @$_dependentConstructor

		constructorArray
