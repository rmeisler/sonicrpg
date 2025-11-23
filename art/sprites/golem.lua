return {
    image = "golem.png",
    starting = "idle",
    w = 70,
    h = 52,

    animations = {
		idle = {
            frames = {{0,0},{1,0}},
			speed = 0.3
        },
		hurt = {
            frames = {{4,3}}
        },
		backward = {
            frames = {{0,0}}
        },
		hide = {
            frames = {{2,2}}
        },
		reveal = {
            frames = {{2,2},{1,2},{0,2},{0,0}},
			speed = 0.2
        },
		heal = {
            frames = {{2,0},{3,0},{4,0},{0,1},{1,1},{1,1},{1,1},{0,1},{4,0},{3,0}},
			speed = 0.2
        },
		rock = {
            frames = {{2,1},{3,1},{4,1}},
			speed = 0.2
        },
		block = {
            frames = {{3,2}}
        },
		laser = {
            frames = {{4,2},{0,3},{1,3},{2,3},{3,3}},
			speed = 0.2
        },
		defup = {
            frames = {{0,4},{1,4},{2,4},{3,4}},
			speed = 0.2
        }
    }
}