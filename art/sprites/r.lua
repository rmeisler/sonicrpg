return {
    image = "r.png",
    starting = "idleright",
    w = 47,
    h = 55,

    animations = {
		pose = {
			frames = {{0,4},{1,4},{2,4},{3,4},{4,4},{4,4},{4,4},{4,4},{4,4},{4,4}},
			speed = 0.1
		},
		
		idleright = {
            frames = {{0,0}}
        },
		idleleft = {
			frames = {{0,1}}
		},
		idledown = {
			frames = {{0,2}}
		},
		idleup = {
			frames = {{0,3}}
		},
		walkright = {
			frames = {{3,0}, {1,0}, {2,0}, {3,0}, {4,0}, {5,0}},
			speed = 0.1
		},
		walkleft = {
			frames = {{3,1}, {1,1}, {2,1}, {3,1}, {4,1}, {5,1}},
			speed = 0.1
		},
		walkdown = {
			frames = {{0,2}, {1,2}, {2,2}, {0,2}, {3,2}, {4,2}},
			speed = 0.1
		},
		walkup = {
			frames = {{0,3}, {1,3}, {2,3}, {0,3}, {3,3}, {4,3}},
			speed = 0.1
		},
		
		dashstart = {
			frames = {{5,3},{6,3},{7,3},{8,3},{9,3},{8,3},{9,3},{8,3},{9,3}},
			speed = 0.15
		},
		dashup = {
			frames = {{8,3},{9,3}},
			speed = 0.05
		},
		dashleft = {
			frames = {{6,1},{7,1},{8,1}},
			speed = 0.05
		},
		dashright = {
			frames = {{6,0},{7,0},{8,0}},
			speed = 0.05
		},
		dashdown = {
			frames = {{8,3},{9,3}},
			speed = 0.05
		},
		
		prepare_goggles = {
			frames = {{12,0}}
		},
		dashright_goggles = {
			frames = {{9,0},{10,0},{11,0}},
			speed = 0.05
		},
		
		hover = {
			frames = {{5,2},{6,2},{7,2}},
			speed = 0.15
		},
		hug = {
			frames = {{5,4}}
		},
		sadleft = {
			frames = {{11,1}}
		},
    }
}