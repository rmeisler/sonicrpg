return {
    image = "buzzbomber.png",
    starting = "idle",
    w = 110,
    h = 66,

    animations = {
        idle = {
            frames = {{0,0},{1,0},{2,0},{3,0}},
			speed = 0.02
        },
		backward = {
            frames = {{4,0},{5,0},{6,0},{7,0}},
			speed = 0.02
        },
		stinger = {
            frames = {{9,0},{10,0},{11,0},{12,0}},
			speed = 0.02
        },
		
		runright = {
            frames = {{9,0},{10,0},{11,0},{12,0}},
			speed = 0.02
        },
		
		hurt = {
			frames = {{8,0}}
		}
    }
}