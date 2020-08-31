return {
    image = "mechaarm.png",
    starting = "idle",
    w = 116,
    h = 75,

    animations = {
        diveleft = {
            frames = {{9,0},{10,0},{11,0},{12,0},{13,0},{14,0},{15,0},{16,0},{17,0}},
			speed = 0.05
        },
		grabbedleft = {
            frames = {{17,0}}
        },
		retractleft = {
            frames = {{17,0},{16,0},{15,0},{14,0},{13,0},{12,0},{11,0},{10,0},{9,0}},
			speed = 0.1
        },
		
		diveright = {
            frames = {{0,0},{1,0},{2,0},{3,0},{4,0},{5,0},{6,0},{7,0},{8,0}},
			speed = 0.05
        },
		grabbedright = {
            frames = {{8,0}}
        },
		retractright = {
            frames = {{8,0},{7,0},{6,0},{5,0},{4,0},{3,0},{2,0},{1,0},{0,0}},
			speed = 0.1
        }
    },
}