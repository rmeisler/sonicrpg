return {
    image = "pressx.png",
    starting = "idle",
    w = 12,
    h = 12,

    animations = {
        nopress = {
            frames = {{0,0}}
        },
		idle = {
            frames = {{0,0},{1,0}},
            speed = 0.2
        },
		rapidly = {
			frames = {{0,0},{1,0},{0,0},{1,0},{0,0},{1,0},{0,0},{1,0},{0,0},{1,0}},
            speed = 0.1
		}
    }
}