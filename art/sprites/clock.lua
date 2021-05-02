return {
    image = "clock.png",
    starting = "idle",
    w = 16,
    h = 16,

    animations = {
        idle = {
            frames = {{0,0}}
        },
		
		ring = {
			frames = {{1,0},{0,0}},
			speed = 0.03
		}
    }
}