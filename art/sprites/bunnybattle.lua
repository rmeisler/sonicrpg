return {
    image = "bunnybattle.png",
    starting = "idle",
    w = 47,
    h = 55,

    animations = {
        idle = {
            frames = {{0,0}}
        },
		backward = {
			frames = {{0,3}}
		},
		victory = {
			frames = {{1,0}}
		},
        crouch = {
            frames = {{0,2}}
        },
        leap = {
            frames = {{0,1},{1,1}},
			speed = 0.05
        },
		leap_idle = {
			frames = {{1,1}}
		},
        kick = {
            frames = {{2,1},{3,1}},
            speed = 0.05
        },
		retract_kick = {
			frames = {{4,1}}
		},
        hurt = {
            frames = {{1,2}}
        },
        dead = {
            frames = {{2,2}}
        },
		extend = {
			frames = {{3,2}}
		},
		
		fly1 = {
			frames = {{3,3},{3,4},{4,3},{4,4}},
			speed = 0.4
		},
		fly2 = {
			frames = {{1,3},{2,3}},
			speed = 0.2
		},
		
		hold = {
			frames = {{0,4}}
		},
		throw = {
			frames = {{1,4},{2,4},{0,5}},
			speed = 0.2
		}
    }
}