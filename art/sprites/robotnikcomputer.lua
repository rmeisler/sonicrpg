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
		active = {
			frames = {{2,0},{3,0}},
			speed = 0.3
		}
    }
}