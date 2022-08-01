return {
    image = "cyclops.png",
    starting = "idleright",
    w = 250,
    h = 183,

    animations = {
		idleright = {
			frames = {{0,0},{1,0}},
			speed = 0.6
		},
		idle = {
			frames = {{0,0},{1,0}},
			speed = 0.6
		},
		backward = {
			frames = {{11,0},{12,0}},
			speed = 0.6
		},
		hurt = {
			frames = {{2,0}}
		},
		roar = {
			frames = {{3,0},{4,0}},
			speed = 0.2
		},
		stomp1 = {
			frames = {{6,0}}
		},
		stomp2 = {
			frames = {{8,0}}
		},
		walkright = {
			frames = {{0,0},{5,0},{6,0},{7,0},{8,0},{9,0},{10,0}},
			speed = 0.13
		},
		walkright_step1 = {
			frames = {{5,0},{6,0},{7,0},{0,0}},
			speed = 0.1
		},
		walkright_step2 = {
			frames = {{8,0},{9,0},{10,0},{0,0}},
			speed = 0.12
		},
		
		dazed = {
			frames = {{2,0},{13,0}},
			speed = 0.3
		},
		
		fall = {
			frames = {{14,0},{15,0}},
			speed = 0.2
		},
		
		prone = {
			frames = {{16,0},{17,0}},
			speed = 0.8
		},
		prone_hurt = {
			frames = {{18,0}}
		},
		
		unprone = {
			frames = {{15,0},{15,0},{15,0},{15,0},{15,0},{15,0},{15,0},{15,0},{14,0},{1,0}},
			speed = 0.1
		},
    }
}