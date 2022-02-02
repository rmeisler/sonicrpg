return {
    image = "ivan.png",
    starting = "meeting_idleup",
    w = 47,
    h = 55,

    animations = {
	    idledown = {
			frames = {{0,2}}
		},
		idleup = {
			frames = {{0,3}}
		},
		attitude = {
			frames = {{1,5}}
		},
	
		meeting_idledown = {
			frames = {{0,2}},
			clip = {0,0,47,44}
		},
		meeting_idleup = {
			frames = {{0,3}},
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