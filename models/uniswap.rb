class Uniswap


	def self.token_info 
		{
			"USDC": "0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8"
		}
	end

	def self.get_swaps pool, first, last_timestamp

		query ="{
  		liquidityPool(id: \"#{pool}\") {
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

	def self.account_info pool, token, decimals=18
		swaps = get_all_swaps pool

		accounts = {}

		swaps.each do |swap|
			
			if !accounts[swap["account"]["id"]] #new account
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

		accounts
	end

	def self.get_balance_weighted_avg_cost_basis pool, token, bounds, decimals=18
		accounts = account_info pool, token, decimals

		total_bought = 0
		total_spent = 0

		accounts.each do |adr, data|
			next if !data["has_bought"] or data["bought_and_unsold"] <= 0			
			data["cost_basis"] = data["usd_spent"] / data["token_bought"]

			# filter out weird data
			next if data["cost_basis"] < bounds[0] or data["cost_basis"] > bounds[1]
			total_bought += data["bought_and_unsold"]
			total_spent += data["cost_basis"] * data["bought_and_unsold"]

		end
		{cb: total_spent / total_bought, accounts: accounts}
	end 

	def self.get_correlation pool1,  pool2
		accounts1 = account_info pool1["adr"], pool1["token"]
		accounts2 = account_info pool2["adr"], pool2["token"]

		#number of accounts with unsold balances after buying
		pool1_unsold_count = 0
		pool2_unsold_count = 0
		

		pool1_in_pool2 = 0
		pool1_in_pool2_adrs = []

		pool2_in_pool1 = 0
		pool2_in_pool1_adrs = []



		accounts1.each do |adr, data|
			if data["bought_and_unsold"] > 0
				pool1_unsold_count += 1

				if accounts2[adr] and accounts2[adr]["bought_and_unsold"] > 0
					pool1_in_pool2 += 1
					pool1_in_pool2_adrs << adr
				end
			end
		end

		accounts2.each do |adr, data|
			if data["bought_and_unsold"] > 0
				pool2_unsold_count += 1

				if accounts1[adr] and accounts1[adr]["bought_and_unsold"] > 0
					pool1_in_pool2 += 1
					pool1_in_pool2_adrs << adr
				end
			end
		end

		results = {}

		results[:pool_1_2_correlation] = pool1_in_pool2 / pool1_unsold_count.to_f
		results[:pool_2_1_correlation] = pool2_in_pool1 / pool2_unsold_count.to_f
		results[:pool1_in_pool2_adrs] = pool1_in_pool2_adrs 
		results[:pool2_in_pool1_adrs] = pool2_in_pool1_adrs 

		results


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
				p response_count
			rescue #prob timeout or something
				p "timeout"
				break
			end
		end
		File.write("./swaps/#{pool}.json", all_swaps.to_json)
		all_swaps


	end

end


=begin

Uniswap.get_all_swaps("0xa6e376c6c2B5739085671a8937eb233eA7f598Ce")

Uniswap.get_balance_weighted_avg_cost_basis "0x32B89D2442b4140c052BdBa2Ac6b03BAd7243286", "0x0c4681e6c0235179ec3d4f4fc4df3d14fdd96017", [.13, 1.45]

Uniswap.get_balance_weighted_avg_cost_basis "0xa6e376c6c2B5739085671a8937eb233eA7f598Ce", "0x2f27118e3d2332afb7d165140cf1bb127ea6975d", [.13, 1.45]


pool1 = {"adr" => "0x32B89D2442b4140c052BdBa2Ac6b03BAd7243286", "token" => "0x0c4681e6c0235179ec3d4f4fc4df3d14fdd96017"}

pool2 = {"adr" => "0xa6e376c6c2B5739085671a8937eb233eA7f598Ce", "token" => "0x2f27118e3d2332afb7d165140cf1bb127ea6975d"}
Uniswap.get_correlation pool1, pool2

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

