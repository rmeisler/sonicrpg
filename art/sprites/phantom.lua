return {
    image = "phantom.png",
    starting = "idle",
    w = 120,
    h = 84,

    animations = {
		idle = {
            frames = {{0,0},{1,0}},
			speed = 0.4
        },
		backward = {
            frames = {{2,0},{3,0}},
			speed = 0.4
        },

		idleright = {
            frames = {{0,0},{1,0}},
			speed = 0.4
        },
		idleleft = {
            frames = {{2,0},{3,0}},
			speed = 0.4
        },
		
		runright = {
            frames = {{0,0},{1,0}},
			speed = 0.4
        },
		runleft = {
            frames = {{2,0},{3,0}},
			speed = 0.4
        },

		hurt = {
			frames = {{11,0}}
		},
		hurtdown = {
			frames = {{11,0}}
		},
		
		spawn_arm = {
			frames = {{4,0},{5,0},{6,0}},
			speed = 0.1
		},
		
		arm_idle = {
			frames = {{6,0},{7,0}},
			speed = 0.4
		},
		
		slash = {
			frames = {{8,0},{9,0},{10,0},{10,0},{10,0},{10,0},{10,0},{10,0},{10,0},{10,0}},
			speed = 0.05
		},
		
		scare = {
			frames = {{11,0},{12,0},{13,0},{12,0},{13,0},{12,0},{13,0},{12,0},{13,0},{12,0},{13,0},{12,0},{13,0},{12,0},{13,0},{12,0},{13,0},{12,0},{13,0}},
			speed = 0.1
		}
    }
}