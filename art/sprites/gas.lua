return {
    image = "gas.png",
    starting = "idle",
    w = 55,
    h = 44,

    animations = {
		start = {
            frames = {{0,0}}
        },
        release = {
            frames = {{0,0},{1,0},{2,0},{3,0},{4,0}},
			speed = 0.2
        },
		idle = {
            frames = {{3,0},{4,0}},
			speed = 0.2
        },

		backward_start = {
            frames = {{5,0}}
        },
		backward_release = {
            frames = {{5,0},{6,0},{7,0},{8,0},{9,0}},
			speed = 0.2
        },
		backward = {
            frames = {{8,0},{9,0}},
			speed = 0.2
        }
    }
}