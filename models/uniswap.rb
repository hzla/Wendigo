class Uniswap


	def self.get_swaps pool, first, last_timestamp

		query ="{
  		liquidityPool(id: \"0x32B89D2442b4140c052BdBa2Ac6b03BAd7243286\") {
	      swaps(where: {timestamp_lt: #{last_timestamp}}, orderBy: timestamp, orderDirection: desc, first: #{first}) {
		      hash
		      timestamp
		      tokenIn {
		        id
		      }
		      amountIn
		      amountInUSD
		      tokenOut {
		        id
		      }
		      amountOut
		      amountOutUSD
		      account {
		        id
		      }
	  	  }
	    }
		}"
	  url = "https://api.thegraph.com/subgraphs/name/messari/uniswap-v3-arbitrum"

	  response = HTTParty.post(url, headers: { 
	    'Content-Type'  => 'application/json'
	  },
	  body: { 
	    query: query
	  }.to_json)


	  parsed_response = JSON.parse(response.body)["data"]["liquidityPool"]["swaps"]
	  {data: parsed_response, next: parsed_response.last["timestamp"]}
	end

	def self.get_all_swaps pool
		if File.exists?("./swaps/#{pool}.json")
			return JSON.parse(File.read("./swaps/#{pool}.json"))
		end


		response_count = 1001
		last_timestamp = Time.now.to_i
		all_swaps = []

		until response_count < 1000 
			begin
				swaps = get_swaps pool, 1000, last_timestamp
				response_count = swaps[:data].length
				last_timestamp = swaps[:next]
				all_swaps += swaps[:data]
			rescue #prob timeout or something
				break
			end
		end
		File.write("./swaps/#{pool}.json", all_swaps.to_json)
		all_swaps


	end

end


=begin

Uniswap.get_all_swaps("0x32B89D2442b4140c052BdBa2Ac6b03BAd7243286")

=end

# "{\n  liquidityPool(id: \"0x32B89D2442b4140c052BdBa2Ac6b03BAd7243286\") {\n\t      swaps(where: {timestamp_lt: 10000000000}, orderBy: timestamp, orderDirection: desc, first: 100) {\n\t\t      hash\n\t\t      timestamp\n\t\t      tokenIn {\n\t\t        id\n\t\t      }\n\t\t      amountIn\n\t\t      amountInUSD\n\t\t      tokenOut {\n\t\t        id\n\t\t      }\n\t\t      amountOut\n\t\t      amountOutUSD\n\t\t      account {\n\t\t        id\n\t\t      }\n\t  \t  }\n\t    }\n}\n\n"