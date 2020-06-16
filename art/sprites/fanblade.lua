return {
    image = "fanblade.png",
    starting = "idle_left",
    w = 64,
    h = 64,

    animations = {
        first = {
            frames = {{0,0},{1,0},{2,0},{3,0},{4,0},{5,0},{6,0},{7,0}},
			speed = 0.05
        },
		second = {
			frames = {{2,0},{3,0},{4,0},{5,0},{6,0},{7,0},{0,0},{1,0}},
			speed = 0.05
		},
		third = {
			frames = {{4,0},{5,0},{6,0},{7,0},{0,0},{1,0},{2,0},{3,0}},
			speed = 0.05
		},
		fourth = {
			frames = {{6,0},{7,0},{0,0},{1,0},{2,0},{3,0},{4,0},{5,0}},
			speed = 0.05
		},
		
		first_idle = {
            frames = {{0,0}}
        },
		second_idle = {
			frames = {{2,0}}
		},
		third_idle = {
			frames = {{4,0}}
		},
		fourth_idle = {
			frames = {{6,0}}
		},
    }
}