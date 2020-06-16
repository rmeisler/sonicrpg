return {
    image = "fadeplatform.png",
    starting = "idle",
    w = 16,
    h = 16,

    animations = {
        idle = {
            frames = {{0,0},{1,0},{2,0},{1,0}},
			speed = 0.1
        },
		gone = {
			frames = {{7,0}}
		},
		disappear = {
            frames = {{1,0},{3,0},{4,0},{5,0},{6,0},{7,0}},
			speed = 0.08
        },
		
		disappear_slow = {
            frames = {{1,0},{3,0},{4,0},{5,0},{6,0},{7,0}},
			speed = 0.3
        },
		reappear = {
            frames = {{7,0},{6,0},{5,0},{4,0},{3,0},{1,0}},
			speed = 0.01
        }
    }
}