return {
    image = "door8.png",
    starting = "closed_right",
    w = 64,
    h = 96,

    animations = {
        closed_right = {
			frames = {{0,0}}
		},
		open_right = {
			frames = {{3,0}}
		},
		opening_right = {
            frames = {{0,0},{1,0},{2,0},{3,0}},
			speed = 0.1
        },
		closing_right = {
            frames = {{3,0},{2,0},{1,0},{0,0}},
			speed = 0.1
        },
		
		closed_left = {
			frames = {{4,0}}
		},
		open_left = {
			frames = {{7,0}}
		},
		opening_left = {
            frames = {{4,0},{5,0},{6,0},{7,0}},
			speed = 0.1
        },
		closing_left = {
            frames = {{7,0},{6,0},{5,0},{4,0}},
			speed = 0.1
        }
    }
}