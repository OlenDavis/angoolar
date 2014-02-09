# This is merely a utility that takes an arguments parameter (the special object arguments, which is neither an object nor an array), and converts it to an actual array (with prototypal methods like splice and slice)
angoolar.argumentsToArray = ( args ) ->
	array = new Array()
	array.push args...
	array

angoolar.prototypallyExtendPropertyObject = ( target, propertyName ) ->
	if target.constructor.__super__? # If the target has a parent class
		angular.extend(
			prototypallyExtendPropertyObject( target.constructor.__super__, propertyName )
			target.constructor::[ propertyName ] or {}
		)
	else
		target.constructor::[ propertyName ] or {}

angoolar.prototypallyMergePropertyArray = ( target, propertyName ) ->
	if target.constructor.__super__? # If the target has a parent class
		_.union(
			prototypallyMergePropertyArray( target.constructor.__super__, propertyName )
			target.constructor::[ propertyName ] or new Array()
		)
	else
		target.constructor::[ propertyName ] or new Array()

# IE8 and prior throws an error when calling delete on an object's property; so, set it to undefined and then ignore any error resulting from calling delete on the object property
angoolar.delete = ( object, property ) ->
	object[ property ] = undefined
	try 
		delete object[ property ]
	catch

angoolar.indexOfByProperty = ( haystack, needle, property = 'id' ) ->
	theNeedle = unless angular.isObject needle
		needleWrapper = {}
		needleWrapper[ property ] = needle
		needleWrapper
	else
		needle

	index = -1
	for anotherNeedle, i in haystack
		if angular.equals theNeedle[ property ], anotherNeedle[ property ]
			index = i
			break

	index

angoolar.findByProperty = ( haystack, needle, property ) ->
	index = angoolar.indexOfByProperty arguments...
	if index >= 0
		haystack[ index ]
	else
		null

angoolar.removeByProperty = ( haystack, needle, property ) ->
	index = angoolar.indexOfByProperty arguments...
	if index >= 0
		haystack.splice index, 1
