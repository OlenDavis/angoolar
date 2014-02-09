
angoolar.RejectedRequest = class RejectedRequest extends angoolar.Request

	constructor: ( rejectedRequest, reason ) ->
		super rejectedRequest

		@$_rejected = yes

		@addReason reason if reason?

	addReason: ( rejectedRequest, reason ) ->
		unless reason?
			reason = rejectedRequest
			rejectedRequest = @

		angoolar.Request::addComment rejectedRequest, "(Rejection reason)\t#{ reason }"

	isWhatItIs: ( possibleRejectedRequest ) ->
		possibleRejectedRequest          .$_rejected   and
		        possibleRejectedRequest  .method?      and
		( _.has possibleRejectedRequest, 'method'    ) and
		        possibleRejectedRequest  .url?         and
		( _.has possibleRejectedRequest, 'url'       ) #and
