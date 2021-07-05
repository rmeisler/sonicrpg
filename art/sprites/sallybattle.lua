return {
    image = "sallybattle.png",
    starting = "idle",
    w = 55,
    h = 55,

    animations = {
        idle = {
            frames = {{0,0}}
        },
		backward = {
			frames = {{4,3}}
		},
		victory = {
			frames = {{1,0}}
		},
        crouch = {
            frames = {{3,0}}
        },
        leap = {
            frames = {{4,0}}
        },
		leap_dodge = {
			frames = {{4,0}}
		},
		nichole_start = {
			frames = {{0,3},{1,3},{2,3}},
			speed = 0.1
		},
		nichole_idle = {
			frames = {{2,3}}
		},
		nichole_retract = {
			frames = {{2,3},{3,3},{0,0}},
			speed = 0.1
		},
        kick = {
            frames = {{0,2},{1,2},{2,2}},
            speed = 0.1
        },
		retract_kick = {
			frames = {{2,2},{3,2}},
			speed = 0.4
		},
        hurt = {
            frames = {{2,0}}
        },
        dead = {
            frames = {{3,1}}
        },
		throw = {
			frames = {{0,1},{1,1},{2,1},{4,1}},
			speed = 0.1
		},
		annoyed = {
			frames = {{2,4}}
		},
		shock = {
			frames = {{1,4}}
		},
		thinking = {
			frames = {{0,4}}
		},
		thinking2 = {
			frames = {{3,4}}
		},
		thinking3 = {
			frames = {{4,4}}
		},
		sad = {
			frames = {{0,5}}
		}
    }
}