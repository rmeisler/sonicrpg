return {
    image = "ratbot.png",
    starting = "idle",
    w = 134,
    h = 100,

    animations = {
		idle = {
            frames = {{11,0}}
        },
		backward = {
			frames = {{14,0}}
		},
		
        idleright = {
            frames = {{11,0}}
        },
		idleleft = {
			frames = {{14,0}}
		},
		idledown = {
			frames = {{11,0}}
		},
		idleup = {
			frames = {{11,0}}
		},
		walkright = {
			frames = {{11,0},{12,0},{11,0},{10,0}},
			speed = 0.3
		},
		walkleft = {
			frames = {{14,0},{15,0},{14,0},{13,0}},
			speed = 0.3
		},
		walkup = {
			frames = {{11,0},{12,0},{11,0},{10,0}},
			speed = 0.3
		},
		walkdown = {
			frames = {{11,0},{12,0},{11,0},{10,0}},
			speed = 0.3
		},

		hurt = {
			frames = {{9,0}}
		},
		
		crouch = {
			frames = {{9,0}}
		},
		
		leap = {
			frames = {{16,0}, {17,0}, {17,0}, {17,0}, {17,0}, {17,0}, {17,0}, {17,0}},
			speed = 0.3
		},
		
		lunge = {
			frames = {{18,0}}
		},
		
		pose = {
			frames = {{2,0},{2,0},{2,0},{2,0},{2,0},{2,0},{2,0}},
			speed = 0.05
		},
		tail = {
			frames = {{3,0}, {4,0}, {4,0}, {4,0}, {4,0}, {4,0}, {4,0}},
			speed = 0.05
		},
		
		electricpose = {
			frames = {{0,0},{1,0},{0,0},{1,0},{0,0},{1,0},{0,0}},
			speed = 0.05
		},
		electrictail = {
			frames = {{3,0}, {5,0}, {6,0}, {5,0}, {6,0}, {5,0}},
			speed = 0.05
		},
    }
}