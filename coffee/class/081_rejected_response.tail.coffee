root = window

root.RejectedResponse = class RejectedResponse extends root.Response

	constructor: ( rejectedResponse, reason ) ->
		super rejectedResponse

		@$_rejected = yes

		@addReason reason if reason?

	addReason: ( rejectedResponse, reason ) ->
		unless reason?
			reason = rejectedResponse
			rejectedResponse = @

		root.Request::addComment rejectedResponse.request, "(Rejection reason)\t#{ reason }"

	isWhatItIs: ( possibleRejectedResponse ) ->
		(
			possibleRejectedResponse.$_rejected or (
				possibleRejectedResponse.status < 200 or 
				possibleRejectedResponse.status >= 300
			)
		) and
		        possibleRejectedResponse  .data?             and
		( _.has possibleRejectedResponse, 'data'           ) and
		        possibleRejectedResponse  .status?           and
		( _.has possibleRejectedResponse, 'status'         ) and 
		        possibleRejectedResponse  .headers?          and
		( _.has possibleRejectedResponse, 'headers'        ) and 
		        possibleRejectedResponse  .config?           and
		( _.has possibleRejectedResponse, 'config'         )

	fromRejectedRequest: ( rejectedRequest ) ->
		new root.RejectedResponse {
				data   : {}
				status : 0
				headers: ( -> )
				config : rejectedRequest
			},
			"Created from rejectedRequest: #{ rejectedRequest.getDescription().replace '\n', '' }"