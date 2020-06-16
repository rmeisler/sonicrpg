return {
    image = "computer.png",
    starting = "idle",
    w = 64,
    h = 64,

    animations = {
        idle = {
            frames = {{0,0},{1,0}},
			speed = 0.2
        },
		
		auth = {
            frames = {{2,0},{3,0},{4,0},{5,0},{6,0},{7,0}},
			speed = 0.1
        },
		
		auth_idle = {
            frames = {{7,0},{8,0}},
			speed = 0.2
        },
		
		hacked = {
            frames = {{9,0},{10,0},{11,0},{12,0},{13,0},{14,0}},
			speed = 0.2
        },
		
		hacked_idle = {
            frames = {{14,0},{15,0},{16,0}, {17,0}},
			speed = 0.1
        },
    }
}