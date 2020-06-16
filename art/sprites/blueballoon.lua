return {
    image = "blueballoon.png",
    starting = "idle",
    w = 32,
    h = 32,

    animations = {
		idle = {
			frames = {{1,0}}
		},
		throw = {
			frames = {{1,0}, {1,0}, {0,0}, {0,0}, {0,0}, {0,0}, {1,0}},
			speed = 0.08
		},
        explode = {
            frames = {{1,0},{2,0},{3,0},{4,0}},
			speed = 0.05
        }
    }
}