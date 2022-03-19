return {
    image = "sallybed.png",
    starting = "empty",
    w = 101,
    h = 62,

    animations = {
		empty = {
			frames = {{0,0}}
		},
		
		sleeping = {
			frames = {{1,0}}
		},
		wake = {
			frames = {{2,0},{1,0},{2,0},{1,0},{2,0},{1,0}},
			speed = 0.2
		},
		awake = {
			frames = {{3,0}}
		},
		sit = {
			frames = {{4,0}}
		}
    }
}