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
			speed = 0.09
		},
		walkleft = {
			frames = {{3,1}, {1,1}, {2,1}, {3,1}, {4,1}, {5,1}},
			speed = 0.09
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
			frames = {{8,3},{9,3}},
			speed = 0.05
		},
		dashright = {
			frames = {{8,3},{9,3}},
			speed = 0.05
		},
		dashdown = {
			frames = {{8,3},{9,3}},
			speed = 0.05
		},
    }
}