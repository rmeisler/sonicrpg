return {
    image = "bbed.png",
    starting = "rest",
    w = 48,
    h = 80,

    animations = {
		rest = {
			frames = {{0,0}}
		},
	
		wakeup1 = {
            frames = {{1,0},{2,0},{1,0},{2,0},{1,0},{2,0},{1,0},{2,0}},
			speed = 0.5
        },
		
		wakeup2 = {
            frames = {{1,0},{2,0},{1,0},{2,0}},
			speed = 0.2
        },
		
		wakeup3 = {
            frames = {{1,0},{2,0},{1,0},{2,0},{1,0},{2,0},{1,0},{2,0}},
			speed = 0.1
        },
	
        wakeup = {
            frames = {{3,0},{4,0},{5,0}},
			speed = 0.1
        },
		
		awake = {
            frames = {{5,0}},
			speed = 0.1
        },
		
		lookright = {
            frames = {{6,0}}
        },
    }
}