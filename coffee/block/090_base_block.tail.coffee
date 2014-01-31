root = window

root.BaseBlock = class BaseBlock extends root.NamedDependent
	$_checkName: -> # This is the one named Dependent that actually doesn't require a name at all