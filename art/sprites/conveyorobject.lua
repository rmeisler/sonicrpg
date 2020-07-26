return {
    image = "conveyorobject.png",
    starting = "right_inactive",
    w = 144,
    h = 80,

    animations = {
        right_inactive = {
            frames = {{0,0}}
        },
		left_inactive = {
            frames = {{3,0}}
        },
		right_active = {
            frames = {{0,0},{1,0},{2,0}},
			speed = 0.1
        },
		left_active = {
            frames = {{3,0},{4,0},{5,0}},
			speed = 0.1
        },
    }
}