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
		glareright = {
			frames = {{4,6}}
		},

		meeting_idledown = {
			frames = {{0,2}},
			clip = {0,0,47,40}
		},
		meeting_idleleft = {
			frames = {{0,1}},
			clip = {0,0,47,40}
		},
		meeting_idleleftshakehead = {
            frames = {{2,7},{3,7},{2,7},{3,7},{1,7}},
			speed = 0.3,
			clip = {0,0,47,40}
        },
		meeting_idleleft_lookdown = {
            frames = {{1,7}},
			clip = {0,0,47,40}
        },
		
		idlerightsad = {
            frames = {{1,6}}
        },
		idlerightshakehead = {
            frames = {{2,6},{3,6},{2,6},{3,6},{1,6}},
			speed = 0.3
        },

		faceleft = {
			frames = {{9,1}}
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