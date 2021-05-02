return {
    image = "rotordoor.png",
    starting = "closed",
    w = 50,
    h = 82,

    animations = {
        closed = {
            frames = {{0,0}}
        },
		open = {
			frames = {{2,0}}
		},
		opening = {
            frames = {{0,0},{1,0},{2,0}},
			speed = 0.1
        }
    }
}