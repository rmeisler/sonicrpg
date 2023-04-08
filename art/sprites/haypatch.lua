return {
    image = "haypatch.png",
    starting = "idle",
    w = 90,
    h = 70,

    animations = {
        idle = {
            frames = {{0,0}}
        },
		bounce = {
            frames = {{1,0},{2,0},{3,0}},
			speed = 0.1
        },
		waffle = {
            frames = {{1,0},{0,0}},
			speed = 0.2
        },
		snow = {
            frames = {{4,0}}
        }
    }
}