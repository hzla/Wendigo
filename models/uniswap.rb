class Uniswap


	def self.token_info 
		{
			"USDC": "0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8"
		}
	end

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

	def self.get_balance_weighted_avg_cost_basis pool, token, decimals=18
		
		swaps = get_all_swaps pool

		accounts = {

		}

		acc_count = 0

		swaps.each do |swap|
			
			if !accounts[swap["account"]["id"]] #new account
				acc_count += 1
				accounts[swap["account"]["id"]] = {}
				accounts[swap["account"]["id"]]["usd_spent"] = 0
				accounts[swap["account"]["id"]]["token_bought"] = 0
				accounts[swap["account"]["id"]]["has_bought"] = false
				accounts[swap["account"]["id"]]["bought_and_unsold"] = 0
				
				#if its a buy
				if swap["tokenOut"]["id"] == token
					accounts[swap["account"]["id"]]["usd_spent"] += swap["amountInUSD"].to_f
					accounts[swap["account"]["id"]]["token_bought"] = swap["amountOut"].to_f / 10**decimals
					accounts[swap["account"]["id"]]["has_bought"] = true
					accounts[swap["account"]["id"]]["bought_and_unsold"] += swap["amountOut"].to_f / 10**decimals
				end
			else # account exists
				#if its a buy
				if swap["tokenOut"]["id"] == token
					accounts[swap["account"]["id"]]["usd_spent"] += swap["amountInUSD"].to_f
					accounts[swap["account"]["id"]]["token_bought"] = swap["amountOut"].to_f / 10**decimals
					accounts[swap["account"]["id"]]["has_bought"] = true
					accounts[swap["account"]["id"]]["bought_and_unsold"] += swap["amountOut"].to_f / 10**decimals
				else #if it's a sell	
					# we only care if they bought before
					if  accounts[swap["account"]["id"]]["has_bought"]
						accounts[swap["account"]["id"]]["bought_and_unsold"] -= swap["amountIn"].to_f / 10**decimals
					end
				end
			end
		end

		
	end 

	def self.get_correlation pool1, pool2

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

Uniswap.get_balance_weighted_avg_cost_basis "0x32B89D2442b4140c052BdBa2Ac6b03BAd7243286", "0x0c4681e6c0235179ec3d4f4fc4df3d14fdd96017"

constrcut hash with accoutn as key: value as follows:
{
	usd_spent int
	token_bought int
	has_bought bool
	token_balance int
}
cb for one user is token_bought / usd_spent
keep track of sum of all tokens bought from pool

calc balance_weighted_avg_cost_basis by adding all cb * share of tokens bought / tokens bought

iterate through swaps

=end

