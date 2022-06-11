return {
    image = "antoinebattle.png",
    starting = "idle",
    w = 47,
    h = 55,

    animations = {
        idle = {
            frames = {{0,2}}
        },
		idle_lookup = {
            frames = {{6,2}}
        },
		backward = {
			frames = {{0,0}}
		},
		victory = {
			frames = {{0,4}}
		},
		crouch = {
			frames = {{0,3}}
		},
		leap = {
			frames = {{2,2}}
		},
		leap_dodge = {
			frames = {{2,2}}
		},
		kick = {
			frames = {{1,2}, {1,3}, {2,3}, {2,3}, {2,3}, {3,2}, {4,2}},
			speed = 0.15
		},
		retract_kick = {
			frames = {{4,2},{4,2},{4,2},{4,2},{2,2},{1,2}},
			speed = 0.15
		},
        hurt = {
            frames = {{3,3}}
        },
        dead = {
            frames = {{5,2}}
        },
		shock = {
			frames = {{13,2}}
		},
		
		scaredhop1 = {
			frames = {{9,2}}
		},
		scaredhop2 = {
			frames = {{10,2}}
		},
		scaredhop3 = {
			frames = {{11,2}}
		},
		scaredhop4 = {
			frames = {{12,2}}
		},
		scaredhop5 = {
			frames = {{13,2}}
		},
		tremble = {
			frames = {  {12,2}, {12,3}, {12,2}, {13,3},
						{12,2}, {12,3}, {12,2}, {13,3},
						{12,2}, {12,3}, {12,2}, {13,3},
						{12,2}, {12,3}, {12,2}, {13,3},
						{12,2}, {12,3}, {12,2}, {13,3}},
			speed = 0.04
		},
		runscared = {
			frames = {{14,3},{15,3}},
			speed = 0.04
		},
		nervous = {
			frames = {{8,2}}
		},
		chefpose = {
			frames = {{1,4}}
		},
		
		idleright = {
            frames = {{0,0}}
        },
		idleleft = {
			frames = {{0,1}}
		},
		idledown = {
			frames = {{2,4}}
		},
		idleup = {
			frames = {{3,4}}
		}
    }
}