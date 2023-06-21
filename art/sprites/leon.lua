return {
    image = "leon.png",
    starting = "idledown",
    w = 47,
    h = 55,

    animations = {
        idleright = {
            frames = {{0,0}}
        },
		idleleft = {
            frames = {{0,1}}
        },
		idledown = {
            frames = {{0,2}}
        },

		coffeeleft = {
            frames = {{10,1},{11,1}},
			speed = 0.5
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