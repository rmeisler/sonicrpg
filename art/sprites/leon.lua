return {
    image = "leon.png",
    starting = "idledown",
    w = 47,
    h = 55,

    animations = {
        idleright = {
            frames = {{0,6}}
        },
		idleleft = {
            frames = {{0,1}}
        },
		idledown = {
            frames = {{0,2}}
        },
		
		idlerightsad = {
            frames = {{1,6}}
        },
		idlerightshakehead = {
            frames = {{2,6},{3,6},{2,6},{3,6},{1,6}},
			speed = 0.3
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