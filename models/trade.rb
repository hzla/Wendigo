class Trade < ActiveRecord::Base
	belongs_to :user
	has_many :actions


	def self.clear
		Trade.destroy_all
		Action.destroy_all
		Trader.destroy_all
	end


	def self.load_to_db
		(95..96).each do |n|
			trades = JSON.parse(File.read("lib/trades/#{n}.json"))
		
			trades.each do |trade|
				# Create trader if new
				trader = Trader.where(address: trade["account"]).first
				if !trader
					trader = Trader.create(address: trade["account"])
				end

				# Add trade
				full_trade = Trade.create(
					tx_hash: trade["id"],
					address: trade["account"],
					fees: trade["fee"].to_f,
					closed: (!!trade["closedPosition"] == true),
					liquidated: (!!trade["liquidatedPosition"] == true),
					trader_id: trader.id,
					pnl: trade["realisedPnl"],
					pnl_percentage: trade["realisedPnlPercentage"],
					size: trade["size"],
					collateral: trade["collateral"],
					size_delta: trade["sizeDelta"],
					collateral_delta: trade["collateralDelta"]
				)

				# Add individual trade actions
				["increaseList", "decreaseList", "closedPosition", "liquidatedPosition"].each do |action_type|
					if trade[action_type]
						trade[action_type].each do |action|

							if action_type == "increaseList" or action_type == "decreaseList"
								Action.create(
									tx_hash: trade["id"],
									method: action_type,
									trader_id: trader.id,
									trade_id: full_trade.id,
									collateral_delta: action["collateralDelta"].to_i,
									size_delta: action["size_delta"].to_i,
									price: action["price"].to_i,
									fee: action["fee"].to_i,
									timestamp: action["timestamp"]
								)
							elsif action_type == "closedPosition"
								action = trade[action_type]

								Action.create(
									tx_hash: trade["id"],
									method: action_type,
									trader_id: trader.id,
									trade_id: full_trade.id,
									collateral_delta: action["collateral"].to_i,
									size_delta: action["size"].to_i,
									price: action["averagePrice"].to_i,
									timestamp: action["timestamp"]
								)
							else #liquidation
								action = trade[action_type]

								Action.create(
									tx_hash: trade["id"],
									method: action_type,
									trader_id: trader.id,
									trade_id: full_trade.id,
									collateral_delta: action["collateral"].to_i,
									size_delta: action["size"].to_i,
									price: action["markPrice"].to_i,
									timestamp: action["timestamp"]
								)
							end
						end
					end
				end
			end
		end
	end


end