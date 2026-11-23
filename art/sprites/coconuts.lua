return {
    image = "coconuts.png",
    starting = "idleleft",
    w = 50,
    h = 43,

    animations = {
		idleright = {
            frames = {{0,0}}
        },
        idleleft = {
            frames = {{2,0}}
        },
		idleup = {
            frames = {{4,0}}
        },
		crouchright = {
			frames = {{1,0}}
		},
		crouchleft = {
			frames = {{3,0}}
		},
		throwright = {
            frames = {{5,0},{6,0}},
			speed = 0.5
        },
    }
}