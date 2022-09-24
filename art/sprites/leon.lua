return {
    image = "leon.png",
    starting = "idledown",
    w = 47,
    h = 55,

    animations = {
        idleright = {
            frames = {{0,0}}
        },
		idledown = {
            frames = {{0,2}}
        },

		walkright = {
            frames = {{0,0},{1,0},{0,0},{2,0}},
			speed = 0.3
        },
		walkdown = {
            frames = {{0,2},{1,2},{0,2},{2,2}},
			speed = 0.3
        },
    }
}