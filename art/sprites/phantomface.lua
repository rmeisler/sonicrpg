return {
    image = "phantomface.png",
    starting = "forwardblink",
    w = 32,
    h = 26,

    animations = {
		right = {
            frames = {{0,0}}
        },
		left = {
            frames = {{1,0}}
        },
		forward = {
            frames = {{2,0}}
        },
		forwardblink = {
            frames = {{2,0},{2,0},{2,0},{2,0},{2,0},{2,0},{2,0},{2,0},{2,0},{2,0},{3,0}},
			speed = 0.4
        },
		blink = {
            frames = {{3,0},{2,0},{3,0},{2,0},{3,0},{2,0}},
			speed = 0.2
        },
		smile = {
            frames = {{4,0}}
        },
		laugh = {
			frames = {{5,0},{6,0}},
			speed = 0.2
		}
    }
}