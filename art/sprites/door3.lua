return {
    image = "door3.png",
    starting = "closed",
    w = 64,
    h = 64,

    animations = {
        closed = {
			frames = {{0,0}}
		},
		open = {
			frames = {{2,0}}
		},
		opening = {
            frames = {{0,0},{1,0},{2,0}},
			speed = 0.2
        }
    }
}