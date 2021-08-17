return {
    image = "b.png",
    starting = "idledown",
    w = 47,
    h = 55,

    animations = {
		pose = {
			frames = {{0,4}}
		},
		shock = {
			frames = {{11,4}}
		},
		
		stepup = {
		    frames = {{0,3},{1,3},{0,3},{5,3}},
			speed = 0.5
		},
		stepback = {
		    frames = {{0,2},{1,2},{0,2},{5,2}},
			speed = 0.5
		},
		
		crouchleft = {
		    frames = {{13,6}}
		},
		crouchright = {
		    frames = {{14,6}}
		},
		jumpleft = {
		    frames = {{15,6}}
		},
		jumpright = {
		    frames = {{16,6}}
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
			frames = {{0,2}, {1,2}, {0,2}, {2,2}},
			speed = 0.2
		},
		walkup = {
			frames = {{1,3}, {2,3}, {3,3}, {2,3},{1,3}, {4,3}, {5,3}, {6,3}, {5,3}, {4,3}},
			speed = 0.08
		},
		
		seriousdown = {
			frames = {{6,2}}
		},
		crouchdown = {
			frames = {{4,2}}
		},
		leapdown = {
			frames = {{5,2}}
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
		}
    }
}