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
            frames = {{0,2},{0,3},{0,4},{0,5},{0,4},{0,3}},
			speed = 0.4
        },
		hurt = {
			frames = {{3,0}}
		},
		hurtright = {
			frames = {{3,0}}
		},
		kicked = {
			frames = {{3,1}}
		},
		kickedright = {
			frames = {{3,1}}
		},
		hurtleft = {
			frames = {{3,2}}
		},
		kickedleft = {
			frames = {{3,3}}
		},
		idleright = {
            frames = {{0,2},{0,3},{0,4},{0,5},{0,4},{0,3}},
			speed = 0.4
        },
		idleleft = {
            frames = {{1,2},{1,3},{1,4},{1,5},{1,4},{1,3}},
			speed = 0.4
        },
		idledown = {
            frames = {{2,2},{2,3},{2,4},{2,5},{2,4},{2,3}},
			speed = 0.4
        },
		staticleft = {
			frames = {{1,4}},
		},
		jitterleft = {
			frames = {{1,4},{3,2},{1,4},{3,2},{1,4},{3,2},{1,4}},
			speed = 0.1
		},
		runright = {
			frames = {{0,0},{0,1}},
			speed = 0.02
		},
		runleft = {
            frames = {{1,0},{1,1}},
			speed = 0.02
        },
		rundown = {
            frames = {{2,0},{2,1}},
			speed = 0.02
        },
    }
}