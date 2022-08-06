return {
    image = "tails.png",
    starting = "idleleft",
    w = 47,
    h = 55,

    animations = {
		pose = {
			frames = {{10,2}}
		},
		shock = {
			frames = {{13,2}}
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
			speed = 0.09
		},
		walkleft = {
			frames = {{1,1}, {2,1}, {3,1}, {4,1}, {5,1}, {6,1}, {7,1}, {8,1}},
			speed = 0.09
		},
		walkdown = {
			frames = {{1,2}, {2,2}, {3,2}, {4,2},{5,2}, {6,2}, {7,2}, {8,2}},
			speed = 0.09
		},
		walkup = {
			frames = {{1,3}, {2,3}, {3,3}, {4,3},{5,3}, {6,3}, {7,3}, {8,3}},
			speed = 0.09
		},
		
		hideright = {
			frames = {{1,4}}
		},
		hideleft = {
			frames = {{3,4}}
		},
		hideup = {
			frames = {{5,4}}
		},
		hidedown = {
			frames = {{7,4}}
		},
		hidedownhand = {
			frames = {{8,4}}
		},
		
		peekright = {
			frames = {{2,4}}
		},
		peekleft = {
			frames = {{4,4}}
		},
		peekup = {
			frames = {{6,4}}
		},
		
		sadright = {
			frames = {{9,0}}
		},
		sadleft = {
			frames = {{9,1}}
		},
		joyright = {
			frames = {{10,0}}
		},
		joyleft = {
			frames = {{10,1}}
		},
		
		flyright = {
			frames = {{11,0},{12,0}},
			speed = 0.1
		},
		flyleft = {
			frames = {{11,1},{12,1}},
			speed = 0.1
		},

		hockeypose = {
			frames = {{11,2}}
		},
		hockeypose2 = {
			frames = {{12,2}}
		},
		
		hockeyflyright = {
			frames = {{13,0},{14,0}},
			speed = 0.1
		},
		hockeyflyleft = {
			frames = {{13,1},{14,1}},
			speed = 0.1
		},
		hockeyflyup = {
			frames = {{13,0},{14,0}},
			speed = 0.1
		},
		hockeyflydown = {
			frames = {{13,1},{14,1}},
			speed = 0.1
		},
    }
}