return {
    image = "robotnikcomputer.png",
    starting = "off",
    w = 320,
    h = 160,

    animations = {
        off = {
            frames = {{0,0}}
        },
		onprison = {
            frames = {{1,0}}
        },
		onsnively = {
            frames = {{4,0},{5,0}},
			speed = 0.1
        },
		onsnivelyoff = {
            frames = {{5,0},{0,0},{5,0},{0,0}},
			speed = 0.1
        },
		active = {
			frames = {{2,0},{3,0}},
			speed = 0.3
		}
    }
}