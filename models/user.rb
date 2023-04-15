class User < ActiveRecord::Base
	
	def recced_position copied_positions

		user_max_size = max_trading_size
		
		position = {}
		position["btcLong"] = 0
		position["ethLong"] = 0
		position["btcShort"] = 0
		position["ethShort"] = 0


		copied_positions.each_with_index do |pos, i|
			trader = Trader.find_by_address(pos["adr"])
			trader_max_size = trader.max_size
			allocation = allocations[i]

			["btc", "eth"].each do |asset|
				["Long", "Short"].each do |dir|
					next if pos["#{asset}#{dir}"] == {}
					pos_data = pos["#{asset}#{dir}"]
					
					if trader_max_size
						sizing_percent = pos_data["size"] / trader_max_size.to_f
					else
						sizing_percent = 0.5
					end
					position["#{asset}#{dir}"] += sizing_percent * (allocation / 100.0) * user_max_size
				end
			end
		end

		p "Max Size: #{user_max_size}, Positions: #{position}"

		position
	end
end


# [{"btcLong"=>{"size"=>29457266, "collateral"=>583638, "averagePrice"=>28051, "entryFundingRate"=>0, "hasRealisedProfit"=>1, "realisedProfit"=>0, "lastIncreasedTime"=>1681136535, "hasProfit"=>1, "delta"=>2463931}, "ethLong"=>{}, "btcShort"=>{}, "ethShort"=>{}, "adr"=>"0xe8c19db00287e3536075114b2576c70773e039bd"}]