class Trader < ActiveRecord::Base
	has_many :trades


	# fills out the pnl at the time of the trade for all of a traders trades
	# gets largest trade, get std of returns (notional)

	def self.update_all_stats
		Trader.all.each do |trader|
			trader.update_stats
		end
	end
	
	def update_stats
		ordered_trades = trades.order(timestamp: :asc)

		current_pnl = 0
		current_pnl_percentage = 0
		max_size = 0
		total_pnl = 0
		closed_trades = 0

		# get pnl info at each point in time 
		ordered_trades.each do |trade|
			current_pnl += (trade.pnl || 0)
			current_pnl_percentage += (trade.pnl_percentage || 0)
			trades.update current_pnl: current_pnl, current_pnl_percentage: current_pnl_percentage

			max_size = trade.size if trade.size > max_size
			
			if trade.closed
				total_pnl += trade.pnl_percentage / 100.0
				closed_trades += 1
			end
		end

		# get std of returns
		

		if closed_trades < 2
			std = 0
		else
			avg_return = total_pnl / closed_trades
			total_deviation = 0

			ordered_trades.each do |trade|
				deviation = (trade.pnl_percentage / 100.0 - avg_return)**2
				total_deviation += deviation
			end

			p total_deviation

			std = Math.sqrt(total_deviation / (ordered_trades.length - 1))
		end

		#pnl 2 decimals
		update pnl: current_pnl, pnl_percentage: current_pnl_percentage, max_size: max_size, trade_count: ordered_trades.length, max_size: max_size, std: std
	end
end


=begin




=end