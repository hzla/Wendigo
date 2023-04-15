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

	$("#add-trader-btn").on('click', function() {
	 	var data = {}

	 	data["adr"] = $("#trader-add").val()

	 	$.post("/user/copy_list/add", data, function(data) {
	 		location.reload()
	 	})
	})

	$(".del-trader").on('click', function() {
	 	var data = {}

	 	data["index"] = $(this).attr('data-pos-id')
	 	console.log(data)
	 	$.post("/user/copy_list/del", data, function(data) {
	 		location.reload()
	 	})
	})

	$(".update-allo").on('click', function() {
	 	var data = {}

	 	data["index"] = $(this).attr('data-pos-id')
	 	data["allo"] = $(this).parents(".table-sub-header").find('.allocation').val()
	 	console.log(data)
	 	$.post("/user/allocations", data, function(data) {
	 		location.reload()
	 	})
	})

	$("#update-sizing").on('click', function() {
	 	var data = {}

	 	data["sizing"] = $('#max-trade').val()
	 	console.log(data)
	 	$.post("/user/sizing", data, function(data) {
	 		location.reload()
	 	})
	})

	$("#calc-cb").on('click', function() {
	 	var data = {}

	 	data["adr"] = $('#pool-address').val()
	 	data["token"] = $('#pool-token').val().toLowerCase()
	 	data["lb"] = $('#pool-lb').val()
	 	data["ub"] = $('#pool-ub').val()
	 	data["decimals"] = $('#decimals').val()

	 	console.log(data)
	 	$(this).text("Loading...")

	 	$.post("/avg_cb", data, function(data) {
	 		$('#calc-cb').text("Calculate")
			$('#content').html(data)
	 	})
	})

	$("#calc-corr").on('click', function() {
	 	var data = {}

	 	data["pool1"] = {}
	 	data["pool2"] = {}

	 	data["pool1"]["adr"] = $('#pool1-adr').val()
	 	data["pool1"]["token"] = $('#pool1-token').val().toLowerCase()

	 	data["pool2"]["adr"] = $('#pool2-adr').val()
	 	data["pool2"]["token"] = $('#pool2-token').val().toLowerCase()


	 	console.log(data)
	 	$(this).text("Loading...")

	 	$.post("/pool_corr", data, function(data) {
	 		$('#calc-corr').text("Calculate")
			$('#content').html(data)
	 	})
	})


})