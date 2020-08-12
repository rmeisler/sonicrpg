return {
    image = "ratbot.png",
    starting = "idle",
    w = 134,
    h = 87,

    animations = {
		idle = {
            frames = {{17,0}}
        },
		backward = {
			frames = {{20,0}}
		},
		
        idleright = {
            frames = {{17,0}}
        },
		idleleft = {
			frames = {{20,0}}
		},
		idledown = {
			frames = {{14,0}}
		},
		idleup = {
			frames = {{11,0}}
		},
		walkright = {
			frames = {{17,0},{18,0},{17,0},{16,0}},
			speed = 0.15
		},
		walkleft = {
			frames = {{20,0},{21,0},{20,0},{19,0}},
			speed = 0.15
		},
		walkup = {
			frames = {{11,0},{12,0},{11,0},{10,0}},
			speed = 0.15
		},
		walkdown = {
			frames = {{14,0},{15,0},{14,0},{13,0}},
			speed = 0.15
		},
		
		runright = {
			frames = {{17,0},{18,0},{17,0},{16,0}},
			speed = 0.15
		},
		runleft = {
			frames = {{20,0},{21,0},{20,0},{19,0}},
			speed = 0.15
		},
		runup = {
			frames = {{11,0},{12,0},{11,0},{10,0}},
			speed = 0.15
		},
		rundown = {
			frames = {{14,0},{15,0},{14,0},{13,0}},
			speed = 0.15
		},

		hurt = {
			frames = {{9,0}}
		},
		hurtdown = {
			frames = {{9,0}}
		},
		
		crouch = {
			frames = {{9,0}}
		},
		
		leap = {
			frames = {{22,0}, {23,0}, {23,0}, {23,0}, {23,0}, {23,0}, {23,0}, {23,0}},
			speed = 0.3
		},
		
		lunge = {
			frames = {{24,0}}
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