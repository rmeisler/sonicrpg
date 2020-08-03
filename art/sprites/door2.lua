return {
    image = "door2.png",
    starting = "closed",
    w = 48,
    h = 64,

    animations = {
        closed = {
			frames = {{0,0}}
		},
		open = {
			frames = {{7,0}}
		},
		opening = {
            frames = {{0,0},{1,0},{2,0},{3,0},{4,0},{5,0},{6,0},{7,0}},
			speed = 0.1
        }
    }
}