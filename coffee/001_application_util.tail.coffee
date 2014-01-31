root = window

# This is merely a utility that takes an arguments parameter (the special object arguments, which is neither an object nor an array), and converts it to an actual array (with prototypal methods like splice and slice)
root.argumentsToArray = ( args ) ->
	array = new Array()
	array.push args...
	array

# This takes a name like 'SomethingCrazy' and turns it into 'something_crazy'
root.camelToUnderscores = ( someText ) -> 
	someText?.
		replace( /([a-z])([A-Z])/g, ( match, lowerPart, upperPart ) -> lowerPart + '_' + upperPart.toLowerCase() ).
		toLowerCase()

# This takes a name like 'SomethingCrazy' and turns it into 'something-crazy'
root.camelToDashes = ( someText ) -> 
	someText?.
		replace( /([a-z])([A-Z])/g, ( match, lowerPart, upperPart ) -> lowerPart + '-' + upperPart.toLowerCase() ).
		toLowerCase()

root.underscorize = ( something ) -> 
	something?.
		toLowerCase().
		replace( /[^\w]/g, '_' ).
		replace /_+/g, '_'

root.lowercaseNoWhitespace = ( something ) -> 
	something?.
		toLowerCase().
		replace /\s/g, ''

root.prototypallyExtendPropertyObject = ( target, propertyName ) ->
	if target.constructor.__super__? # If the target has a parent class
		_.extend(
			prototypallyExtendPropertyObject( target.constructor.__super__, propertyName )
			target.constructor::[ propertyName ] or {}
		)
	else
		target.constructor::[ propertyName ] or {}

root.prototypallyMergePropertyArray = ( target, propertyName ) ->
	if target.constructor.__super__? # If the target has a parent class
		_.union(
			prototypallyMergePropertyArray( target.constructor.__super__, propertyName )
			target.constructor::[ propertyName ] or new Array()
		)
	else
		target.constructor::[ propertyName ] or new Array()

# IE8 and prior throws an error when calling delete on an object's property; so, set it to undefined and then ignore any error resulting from calling delete on the object property
root.delete = ( object, property ) ->
	object[ property ] = undefined
	try 
		delete object[ property ]
	catch

root.escapeColons = ( text ) ->
	text?.
		replace( /:/g, '\\:' )

root.indexOfByProperty = ( haystack, needle, property = 'id' ) ->
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

root.findByProperty = ( haystack, needle, property ) ->
	index = root.indexOfByProperty arguments...
	if index >= 0
		haystack[ index ]
	else
		null

root.removeByProperty = ( haystack, needle, property ) ->
	index = root.indexOfByProperty arguments...
	if index >= 0
		haystack.splice index, 1
