return {
    image = "door6.png",
    starting = "closed",
    w = 64,
    h = 69,

    animations = {
        closed = {
			frames = {{0,0}}
		},
		open = {
			frames = {{3,0}}
		},
		opening = {
            frames = {{0,0},{1,0},{2,0},{3,0}},
			speed = 0.1
        }
    }
}