return {
    image = "cambot2.png",
    starting = "idle",
    w = 64,
    h = 96,

    animations = {
        idle = {
            frames = {{0,0},{1,0},{2,0},{1,0}},
			speed = 0.2
        },
		backward = {
            frames = {{5,0},{6,0},{7,0},{6,0}},
			speed = 0.2
        },

		idleright = {
            frames = {{0,0},{1,0},{2,0},{1,0}},
			speed = 0.2
        },
		idleleft = {
			frames = {{5,0},{6,0},{7,0},{6,0}},
			speed = 0.2
		},
		idledown = {
			frames = {{8,0},{9,0},{10,0},{9,0}},
			speed = 0.2
		},		
		idleup = {
			frames = {{11,0},{12,0},{13,0},{12,0}},
			speed = 0.2
		},
		
		walkright = {
            frames = {{3,0},{1,0},{2,0},{1,0},{0,0},{1,0},{2,0},{1,0},{0,0},{1,0},{2,0},{1,0}},
			speed = 0.2
        },
		walkleft = {
			frames = {{5,0},{6,0},{7,0},{6,0}},
			speed = 0.2
		},
		walkdown = {
			frames = {{8,0},{9,0},{10,0},{9,0}},
			speed = 0.2
		},
		walkup = {
			frames = {{11,0},{12,0},{13,0},{12,0}},
			speed = 0.2
		},
		
		lightwalkright = {
            frames = {{0,0}},
			speed = 0.2
        },
		lightwalkleft = {
			frames = {{5,0}},
			speed = 0.2
		},
		lightwalkdown = {
			frames = {{8,0}},
			speed = 0.2
		},		
		lightwalkup = {
			frames = {{11,0}},
			speed = 0.2
		},
		
		lightdown = {
			frames = {{8,0}}
		},
		lightup = {
			frames = {{11,0}}
		},
		lightleft = {
			frames = {{5,0}}
		},
		lightright = {
			frames = {{0,0}}
		},
		
		runright = {
            frames = {{0,0}}
        },
		runleft = {
			frames = {{5,0}}
		},
		rundown = {
			frames = {{8,0}}
		},
		runup = {
			frames = {{11,0}}
		},
		
		hurt = {
			frames = {{0,0}}
		},
		
		hurtleft = {
			frames = {{4,0}}
		},
		hurtright = {
			frames = {{0,0}}
		},
		hurtdown = {
			frames = {{8,0}}
		},
		hurtup = {
			frames = {{8,0}}
		},

        side = {
            frames = {{1,0}}
        }
    }
}