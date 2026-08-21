return {
    image = "cheeta.png",
    starting = "idle",
    w = 115,
    h = 55,

    animations = {
        idle = {
            frames = {{0,2},{0,3},{0,4},{0,5},{0,4},{0,3}},
			speed = 0.4
        },
		backward = {
            frames = {{1,2},{1,3},{1,4},{1,5},{1,4},{1,3}},
			speed = 0.4
        },
		idleright = {
            frames = {{0,2},{0,3},{0,4},{0,5},{0,4},{0,3}},
			speed = 0.4
        },
		idleleft = {
            frames = {{1,2},{1,3},{1,4},{1,5},{1,4},{1,3}},
			speed = 0.4
        },
		runright = {
			frames = {{0,2},{0,3},{0,4},{0,5},{0,4},{0,3}},
			speed = 0.05
		},
		runleft = {
            frames = {{1,2},{1,3},{1,4},{1,5},{1,4},{1,3}},
			speed = 0.05
        },
    }
}