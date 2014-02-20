
angoolar.Named = class Named
	# IMPORTANT: this MUST be overriden in extending directives because otherwise we'd be inadvertently 
	# overwriting any directives sharing a prototypal parent's $_name that were already attached 
	# to the scope.
	# $_name: "Named" # Your extending Named *must* declare its own $_name property to function - this is due to minification
	
	# This allows us to easily separate different implementations of similar objects based on domain.
	# For instance, two directives that communicate with an API and are identical aside from *which*
	# API they communicate with could be differentiated hilariously simply by having the second extend
	# the first, overriding its API angoolar path (I'm assuming it's declared prototypally) and overriding
	# its _prefix with something else - this way, you can actually refer to them both in markup
	# by identical names different only in a prefix that should be indicative of the difference.
	$_prefix: angoolar.defaultPrefix or ""
	
	# When attaching this to Angular, we call this to ensure that $_name is actually defined on this
	# instance.
	$_checkName: ->
		unless @$_name? and _.has @, "$_name"
			throw new Error "Cannot use, #{ @constructor.name }, here because it doesn't define its $_name is #{ $_name }."

	# Anywhere this is referred to in code, it should be referred to as the result of this function, 
	# merely $_name.
	$_makeName: ->
		@$_prefix + @$_name

	# For convenience and clarity, this is placed here
	$_addToAngular: ->
		@$_checkName()