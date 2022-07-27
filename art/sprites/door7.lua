return {
    image = "door4.png",
    starting = "closed",
    w = 96,
    h = 80,

    animations = {
        closed = {
			frames = {{0,0}}
		},
		open = {
			frames = {{6,0}}
		},
		opening = {
            frames = {{0,0},{1,0},{2,0},{3,0},{4,0},{5,0},{6,0}},
			speed = 0.1
        }
    }
}