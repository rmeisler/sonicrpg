return {
    image = "ivan.png",
    starting = "meeting_idleup",
    w = 47,
    h = 55,

    animations = {
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
			speed = 0.18
		},
		walkup = {
			frames = {{1,3}, {2,3}, {3,3}, {4,3},{5,3}, {6,3}, {7,3}, {8,3}},
			speed = 0.09
		},
		idleup_lookleft = {
			frames = {{0,5}}
		},
		idleup_lookright = {
			frames = {{3,5}}
		},
		attitude = {
			frames = {{1,5}}
		},
		snow_attitude = {
			frames = {{2,5}}
		},
	
		meeting_idledown = {
			frames = {{0,2}},
			clip = {0,0,47,44}
		},
		meeting_idleup = {
			frames = {{0,3}},
			clip = {0,0,47,44}
		},
		meeting_idleleft = {
			frames = {{0,1}},
			clip = {0,0,47,44}
		},
		meeting_idleup_lookleft = {
			frames = {{0,5}},
			clip = {0,0,47,44}
		},
		meeting_idledown_attitude = {
			frames = {{1,5}},
			clip = {0,0,47,44}
		}
    }
}