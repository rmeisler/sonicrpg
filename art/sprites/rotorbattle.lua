return {
    image = "rotorbattle.png",
    starting = "idle",
    w = 65,
    h = 55,

    animations = {
        idle = {
            frames = {{0,1}}
        },
		backward = {
            frames = {{0,0}}
        },
		victory = {
			frames = {{0,4}}
		},
		frozen = {
			frames = {{7,1}}
		},
		cold = {
			frames = {{8,1}}
		},
		shock = {
			frames = {{8,1}}
		},
		prethrow = {
			frames = {{1,1}}
		},
		throw = {
			frames = {{1,1},{2,1},{3,1},{4,1}},
			speed = 0.1
		},
        hurt = {
            frames = {{5,1}}
        },
        dead = {
            frames = {{6,1}}
        },
    }
}