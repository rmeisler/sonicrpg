return {
    image = "factorybot.png",
    starting = "idle",
    w = 50,
    h = 70,

    animations = {
		idle = {
            frames = {{2,0}}
        },
		backward = {
			frames = {{3,0}}
		},
		hurt = {
			frames = {{2,0}}
		},
	
        idledown = {
            frames = {{0,0}}
        },
		idleup = {
            frames = {{1,0}}
        },
		idleright = {
            frames = {{2,0}}
        },
		idleleft = {
            frames = {{3,0}}
        },
		
		walkright = {
            frames = {{2,0},{2,0},{2,0},{2,0}},
			speed = 0.2
        },
		walkleft = {
            frames = {{3,0},{3,0},{3,0},{3,0}},
			speed = 0.2
        },
		walkdown = {
            frames = {{0,0},{0,0},{0,0},{0,0}},
			speed = 0.2
        },
		walkup = {
            frames = {{1,0},{1,0},{1,0},{1,0}},
			speed = 0.2
        },
		
		rundown = {
            frames = {{0,0},{0,0},{0,0},{0,0}},
			speed = 0.2
        },
		runup = {
            frames = {{1,0},{1,0},{1,0},{1,0}},
			speed = 0.2
        },
		runright = {
            frames = {{2,0},{2,0},{2,0},{2,0}},
			speed = 0.2
        },
		runleft = {
            frames = {{3,0},{3,0},{3,0},{3,0}},
			speed = 0.2
        },
		
		lightdown = {
            frames = {{0,0}}
        },
		lightup = {
            frames = {{1,0}}
        },
		lightright = {
            frames = {{2,0}}
        },
		lightleft = {
            frames = {{3,0}}
        },
		
		lightwalkright = {
            frames = {{2,0},{2,0},{2,0},{2,0}},
			speed = 0.2
        },
		lightwalkleft = {
            frames = {{3,0},{3,0},{3,0},{3,0}},
			speed = 0.2
        },
		lightwalkdown = {
            frames = {{0,0},{0,0},{0,0},{0,0}},
			speed = 0.2
        },
		lightwalkup = {
            frames = {{1,0},{1,0},{1,0},{1,0}},
			speed = 0.2
        },
    }
}