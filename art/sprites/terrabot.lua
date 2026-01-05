return {
    image = "terrabot.png",
    starting = "idle",
    w = 222,
    h = 138,

    animations = {
        idle = {
            frames = {{0,0},{1,0}},
			speed = 0.5
        },
		still = {
            frames = {{0,0}}
        },
		hurt = {
			frames = {{0,0},{1,0}},
			speed = 0.5
		},
		getangry = {
            frames = {{0,0},{2,0},{1,0},{3,0},{0,0},{2,0},{1,0},{3,0},{0,0},{2,0},{1,0},{3,0},{0,0},{2,0},{1,0},{3,0}},
			speed = 0.25
        },
		angryidle = {
            frames = {{2,0},{3,0}},
			speed = 0.5
        },
		roar = {
            frames = {{4,0}}
        },
    }
}