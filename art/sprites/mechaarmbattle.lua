return {
    image = "mechaarmbattle.png",
    starting = "idle",
    w = 400,
    h = 93,

    animations = {
		intro = {
			frames = {{0,0},{1,0}},
			speed = 0.02
		},
		idle = {
			frames = {{3,0},{4,0}},
			speed = 0.4
		},
		backward = {
			frames = {{5,0},{6,0}},
			speed = 0.4
		},
		hurt = {
			frames = {{2,0}}
		},
	
        dive1 = {
            frames = {{11,0},{12,0},{13,0},{14,0}},
			speed = 0.05
        },
		grab1_1 = {
			frames = {{14,0}}
		},
		grab1_2 = {
			frames = {{13,0}}
		},
		grab1_3 = {
			frames = {{12,0}}
		},
		grab1_4 = {
			frames = {{11,0}}
		},
		grab1_finish = {
			frames = {{4,0}, {1,0}, {0,0}},
			speed = 0.2
		},
		
		dive2 = {
            frames = {{7,0},{8,0},{9,0},{10,0}},
			speed = 0.05
        },
		grab2_1 = {
			frames = {{10,0}}
		},
		grab2_2 = {
			frames = {{9,0}}
		},
		grab2_3 = {
			frames = {{8,0}}
		},
		grab2_4 = {
			frames = {{7,0}}
		},
		grab2_finish = {
			frames = {{4,0}, {1,0}, {0,0}},
			speed = 0.2
		},
    },
}