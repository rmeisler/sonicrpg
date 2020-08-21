return {
    image = "rover.png",
    starting = "crouched",
    w = 75,
    h = 81,

    animations = {
		idle = {
			frames = {{1,0}}
		},
		
		crouched = {
			frames = {{1,0}}
		},
		
		backward = {
			frames = {{3,0}}
		},
		
		upright = {
            frames = {{0,0}}
        },
		
		transition = {
			frames = {{1,0}, {0,0},{1,0}, {0,0},{1,0}, {0,0},{1,0}, {0,0},{1,0}, {0,0},{1,0}, {0,0}},
			speed = 0.05
		},
		
		hurt = {
			frames = {{1,0}}
		},
		
		-- Animations for non-battle
		hurtright = {
			frames = {{1,0}}
		},
		
		hurtleft = {
			frames = {{1,0}}
		},
		
		runright = {
			frames = {{1,0}}
		},
		
		runleft = {
			frames = {{1,0}}
		},
		
		runup = {
			frames = {{2,0}}
		},
		
		walkright = {
			frames = {{1,0}}
		},
		
		walkleft = {
			frames = {{1,0}}
		},
		
		walkup = {
			frames = {{2,0}}
		},
		
		idleright = {
			frames = {{1,0}}
		},
		
		idleleft = {
			frames = {{3,0}}
		},
		
		idleup = {
			frames = {{2,0}}
		}
		
    }
}