class Trader < ActiveRecord::Base
	has_many :trades


	# fills out the pnl at the time of the trade for all of a traders trades
	# gets largest trade, get std of returns (notional)

	def self.update_all_stats
		Trader.all.each do |trader|
			trader.update_stats
		end
	end




	def self.stats_for_time_period start, finish
		traders = {}
		all.each_with_index do |trader, i|
			p i
			traders[trader.id] = trader.get_stats_for_time_period
		end
		traders
	end

	def get_stats_for_time_period start=0, finish=1681506810
		found_trades = trades.closed_between(start, finish)

		pnl = 0
		pnl_percentage = 0
		wins = 0
		losses = 0

		found_trades.each do |trade|
			pnl += trade.pnl
			pnl_percentage += trade.pnl_percentage

			if trade.pnl > 0 
				wins += 1
			else
				losses += 1
			end
		end

		winrate = wins.to_f / found_trades.length

		{pnl: pnl, pnl_percentage: pnl_percentage, winrate: winrate, trade_count: found_trades.length}
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

	def self.search params
		start = params["start"] or 0
		finish = params["finish"] or Time.now.to_i


		trader_stats = stats_for_time_period start, finish

		
		min_trade_count = params["trade_count"].to_i 
		min_winrate = params["winrate"].to_i / 100.0 
		min_pnl = params["pnl"].to_i * 10**30
		min_pnl_percentage = params["pnl_percentage"].to_i * 100


		matches = []
		result = []

		trader_stats.each do |id, stats|
			next if stats[:pnl] < min_pnl
			next if stats[:pnl_percentage] < min_pnl_percentage
			next if stats[:trade_count] < min_trade_count 
			next if stats[:winrate] < min_winrate

			matches << id
		end

		matched_traders = find(matches)
		
		matches.each_with_index do |id, i|
			result << [matched_traders[i], trader_stats[id]]
		end

		result
	end
end


=begin

SEARCH CRITIERIA


pnl 
pnl percentage 
time period


std
min trade count
min win rate

params = {"pnl" => 0, "trade_count" => 2, "pnl_percentage" => 0, "winrate" => 0}




=end