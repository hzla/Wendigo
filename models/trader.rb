class Trader < ActiveRecord::Base
	has_many :trades


	# fills out the pnl at the time of the trade for all of a traders trades
	# gets largest and average size
	
	def update_stats
		ordered_trades = trades.order(timestamp: :asc)

		current_pnl = 0
		current_pnl_percentage = 0

		ordered_trades.each do |trade|
			current_pnl += (trade.pnl || 0)
			current_pnl_percentage += (trade.pnl_percentage || 0)
			trades.update current_pnl: current_pnl, current_pnl_percentage: current_pnl_percentage

			p current_pnl / 10**30
		end

		update pnl: current_pnl, pnl_percentage: current_pnl_percentage
	end

end
