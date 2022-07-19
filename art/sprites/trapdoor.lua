return {
    image = "trapdoor.png",
    starting = "closed",
    w = 128,
    h = 96,

    animations = {
        closed = {
            frames = {{0,0}}
        },
		opening = {
            frames = {{1,0},{2,0},{3,0}},
			speed = 0.1
        },
		open = {
            frames = {{3,0}}
        }
    }
}