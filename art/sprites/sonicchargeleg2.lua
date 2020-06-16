return {
    image = "sonicchargeleg2.png",
    starting = "right",
    w = 47,
    h = 55,

    animations = {
        right = {
            frames = {{0,0}}
        },
		left = {
            frames = {{1,0}}
        },
		down = {
            frames = {{2,0},{3,0},{4,0},{5,0},{6,0},{7,0},{8,0},{9,0}},
			speed = 0.01
        },
		
		slowleft = {
			frames = {{10,0},{11,0},{12,0},{13,0},{14,0},{15,0},{16,0},{17,0}},
			speed = 0.05
		},
		slowdown = {
            frames = {{2,0},{3,0},{4,0},{5,0},{6,0},{7,0},{8,0},{9,0}},
			speed = 0.05
        },
    }
}