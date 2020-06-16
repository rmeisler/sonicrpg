return {
    image = "hoverbot.png",
    starting = "idle",
    w = 100,
    h = 100,

    animations = {
        idle = {
            frames = {{0,0},{1,0},{2,0},{1,0}},
			speed = 0.3
        },
		backward = {
            frames = {{3,0},{4,0},{5,0},{4,0}},
			speed = 0.3
        },
		
		idleleft = {
			frames = {{3,0},{4,0},{5,0},{4,0}},
			speed = 0.3
		},
		idleright = {
			frames = {{0,0},{1,0},{2,0},{1,0}},
			speed = 0.3
		},
		
		crashright = {
			frames = {{6,0},{7,0},{8,0}},
			speed = 0.09
		},
		idlecrashright = {
			frames = {{8,0}}
		}
    }
}