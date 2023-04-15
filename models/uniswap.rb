class Uniswap


	def get_swaps pool, first, last_timestamp

		query = "{
	    LiquidityPool(where: {id: #{pool}}) {
	      swaps(where: {timestamp_lt: #{last_timestamp}}, orderBy: timestamp, orderDirection: desc, first: #{first}) {
		      hash
		      timestamp
		      tokenIn
		      amountIn
		      amountInUSD
		      tokenOut
		      amountOut
		      amountOutUSD
		      account
	  	  }
	    }
	  }"
	  url = "https://thegraph.com/hosted-service/subgraph/messari/uniswap-v3-arbitrum"
	  response = HTTParty.post(url, headers: { 
	    'Content-Type'  => 'application/json'
	  },
	  body: { 
	    query: query
	  }.to_json)

	  parsed_response = JSON.parse(response.body)


	   swaps = JSON.parse(response.body)["data"]["trades"]
	end

end


=begin

Uniswap.get_swaps()

=end