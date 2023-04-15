$(document).ready(function() {

	$( "#time-start" ).datepicker({
		dateFormat: "@"
	});
	
	$( "#time-end" ).datepicker({
		dateFormat: "@"
	});


	$('#submit-search').on('click', function(){
		var query = {}

		query["start"] = $('#time-start').val() || 0
		query["finish"] = $('#time-end').val() || 1000000000
		query["pnl"] = $('#min-pnl').val() || 0
		query["pnl_percentage"] = $('#min-pnl-perc').val() || 0
		query["winrate"] = $('#min-win').val() || 0
		query["trade_count"] = $('#min-trade').val() || 1

		console.log(query)

		$(this).text("Loading...")

		$.post("/search", query, function(data){
			$('#submit-search').text("Search")
			$('#trader-table-body').html(data)
		})



	})


})