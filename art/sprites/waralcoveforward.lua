return {
    image = "waralcoveforward.png",
    starting = "right",
    w = 450,
    h = 300,
	
	inner_offsets = {
		right = {668, -66},
		left = {90, -66}
	},

    animations = {
		right = {
			frames = {{0,0}}
		},
		
		left = {
			frames = {{1,0}}
		},
		
		right_clipped = {
			frames = {{0,0}},
			clip = {100,0,350,300}
		},
		left_clipped = {
			frames = {{1,0}},
			clip = {0,0,350,300}
		},
    }
}