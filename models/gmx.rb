class Gmx

	attr_accessor :reader, :wbtc, :weth, :usdc

	def initialize
		client = Ethereum::HttpClient.new('https://weathered-polished-seed.arbitrum-mainnet.discover.quiknode.pro/3645e6d37df1cdfaba185b39d45eff7d16238456/')
		address = "0x22199a49A999c351eF7927602CFB187ec3cae489"
		abi = JSON.parse(File.open("lib/abis/gmx.json").read)
		
		@reader = Ethereum::Contract.create(name: "GMX", address: address, abi: abi, client: client)
		@wbtc = "0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f"
		@weth = "0x82aF49447D8a07e3bd95BD0d56f35241523fBab1"
		@usdc = "0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8"
	end

	def positions(account)
		vault = "0x489ee077994B6658eAfA855C308275EAd8097C4A"
		collateral_tokens = [wbtc,weth,usdc,usdc]
		index_tokens = [wbtc,weth,wbtc,weth]
		is_long = [true,true,false,false]
		positions = reader.call.get_positions(vault, account, collateral_tokens, index_tokens, is_long)
		format_positions(positions)
	end

	def format_positions(positions)
		formatted = {}
		position_names = ["btcLong", "ethLong", "btcShort", "ethShort"]
		fields = ["size","collateral", "averagePrice", "entryFundingRate", "hasRealisedProfit", "realisedProfit", "lastIncreasedTime", "hasProfit", "delta"]
		divisors = [30,30,30,10,0,0,0,0,30]

		position_names.each_with_index do |pos, i|
			formatted[position_names[i]] = {}
			fields.each_with_index do |field, j|
				idx = i * 9 + j
				if j == 0 && positions[idx] == 0
					break
				end
				formatted[position_names[i]][fields[j]] = (positions[idx] /  10**divisors[j])
			end
		end
		formatted
	end
end


=begin
tracklist 
["0x367f7def4c05f4ae7ae47f88e270f8c0c85a9273",
"0x48202a51c0d5d81b3ebed55016408a0e0a0afaae",
"0xb7a98544083a5f6dd3bcf267aba5a714e3f515f4",
"0x7b7736a2c07c4332ffad45a039d2117ae15e3f66"]

=end