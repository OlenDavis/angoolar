root = window

root.Flags = class Flags
	constructor: ( @value = 0 ) ->

	isSet: ( flag = null ) ->
		if flag?
			flag is ( @value & flag )
		else
			@value isnt 0

	set: ( flag ) ->
		@value |= flag

	unset: ( flag ) ->
		@value &= ! flag

	toggle: ( flags ) ->
		flagsToUnset = flags & @value # flags that are true in both
		flagsToSet   = flags ^ @value # flags that are true in the given flags, and false in our value

		@unset flagsToUnset
		@set   flagsToSet