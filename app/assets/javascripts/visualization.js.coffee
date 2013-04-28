# Get the global namespace so that we can make things global
window = (exports ? this)
# max and min font-size for visualization
max_size = 40
min_size = 15

# This function extracts the colors and frequencies from our input data
window.setup_visualize = ->
	window.all_colors = []
	window.all_facet_nums = []
	window.all_facet_names = []
	window.colormap = {}
	window.frequencies = {}
	facets = $("li.vis_facet")
	
	for facet in facets
		color = $("input.color", facet).val()
		facet_num = $("input.order", facet).val()
		facet_name = facet.textContent
		window.all_colors.push(color)
		window.all_facet_nums.push(facet_num)
		window.all_facet_names.push(facet_name)
		window.frequencies[facet_num] = JSON.parse($("input.freq", facet).val())

		
	# Clicking on a facet sets the color
	$("li.vis_facet").click ->
		window.select_facet($(this))

	chart = new google.visualization.PieChart(document.getElementById('chart_div'));

	# moseover shows highlight data
	words = $("span.word")	
	words.each( (i,word) ->

		r = frequencies[0][i]
		g = frequencies[1][i]
		b = frequencies[2][i]

		$(word).mouseenter( () ->
			current_word = this.textContent 
			$("span.current-word").text(this.textContent)
			$(this).css("text-decoration","underline")
			for facet_num in all_facet_nums 
				console.log(facet_num, frequencies[facet_num][i])
				$("span.red-percent").text(Math.round(r*100) + "%")
				$("span.green-percent").text(Math.round(g*100) + "%")
				$("span.blue-percent").text(Math.round(b*100) + "%")

			dataArray = [ 
				['Facet', 'Highlights'],
				[ window.all_facet_names[0], r ], 
				[ window.all_facet_names[1], g ], 
				[ window.all_facet_names[2], b ]
			]

			data = google.visualization.arrayToDataTable(dataArray);
			options = {
          	title: 'Highlights for "' + current_word + '"'
				colors: [
					$('.red-vis').css('color'),
					$('.green-vis').css('color'),
					$('.blue-vis').css('color'),
				]
        	};
			chart.draw(data, options);
		)
		$(word).mouseout( () ->
			$(this).css("text-decoration","none")
		)
	)


# This function selects a facet, gives the box a border, and highlights text
window.select_facet = (facet) ->
	current_color = $("input.color", facet).val()
	console.log(current_color)
	current_num = $("input.order", facet).val()
	$("span.facet.border").removeClass("border")
	$(facet).find("span.facet").addClass("border")

	words = d3.selectAll("span.word")
	for color in window.all_colors
		words.classed(color+"-vis", false)

	if current_color=='winning'
		words.data(window.frequencies[0])
			.transition()
			.style("font-size", (d) -> min_size + "px")

		words = $("span.word")
		words.each( (i,word) ->

			r = frequencies[0][i]
			g = frequencies[1][i]
			b = frequencies[2][i]
			
			f=150

			word_freqs = [['red',r],['green',g],['blue',b]];
			word_freqs.sort (a,b) ->
				return ((a[1] < b[1]) ? -1 : ((a[1] > b[1]) ? 1 : 0));

			#no highlighting gets grey, ties get pink
			#winning_color = ((a[0][1] > a[1][1]) ? a[0][0] : ((a[0][1] == 0) ? "grey" : "pink"))
			#winning_color = ((word_freqs[0][1] > word_freqs[1][1]) ? word_freqs[0][0] : "pink")

			if word_freqs[0][1] > word_freqs[1][1]
				winning_color = word_freqs[0][0]
				$(word).toggleClass(winning_color + "-vis", true)
			else if word_freqs[0][1] != 0
				$(word).css('color', 'black')
			else 
				$(word).css('color', 'lightgrey')

			#$(word).css('color', 'rgb('+Math.round(f*frequencies['red'][i])+','+Math.round(f*frequencies['green'][i])+','+Math.round(f*frequencies['blue'][i])+')')
		)

	else
		min = Math.min.apply @, window.frequencies[current_num]
		max = Math.max.apply @, window.frequencies[current_num]
		multiplier = if max == 0 then 0 else (max_size-min_size)/(max-min)
		# sets color and font-size by linear interpolation
		words.data(window.frequencies[current_num])
			.style("color", "") #clear color from 'winning' viz
			.classed(current_color+"-vis", (d) -> (d > 0))
			.transition()
			.style("font-size", (d) -> (min_size+(d-min)*multiplier) + "px" )
