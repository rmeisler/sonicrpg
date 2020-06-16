return {
    image = "bunny.png",
    starting = "idleleft",
    w = 47,
    h = 55,

    animations = {
		pose = {
			frames = {{0,4}}
		},
		shock = {
			frames = {{11,4}}
		},
		
		leapdown = {
			frames = {{5,2}}
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
			frames = {{1,0}, {2,0}, {3,0}, {4,0}, {5,0}, {6,0}, {7,0}, {8,0}},
			speed = 0.08
		},
		walkleft = {
			frames = {{1,1}, {2,1}, {3,1}, {4,1}, {5,1}, {6,1}, {7,1}, {8,1}},
			speed = 0.08
		},
		walkdown = {
			frames = {{1,2}, {2,2}, {3,2}, {4,2},{5,2}, {6,2}, {7,2}, {8,2}},
			speed = 0.08
		},
		walkup = {
			frames = {{1,3}, {2,3}, {3,3}, {4,3},{5,3}, {6,3}, {7,3}, {8,3}},
			speed = 0.08
		},
		
		extendright = {
			frames = {{9,0}}
		},
		extendleft = {
			frames = {{9,1}}
		},
		extenddown = {
			frames = {{9,2}}
		},
		extendup = {
			frames = {{9,3}}
		}
    }
}