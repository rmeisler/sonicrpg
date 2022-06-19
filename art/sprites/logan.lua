return {
    image = "logan.png",
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
		attitude = {
			frames = {{1,5}}
		},
		irritated = {
			frames = {{1,6}}
		},
		shock = {
			frames = {{11,4}}
		},
		
		meeting_idledown = {
			frames = {{0,2}},
			clip = {0,0,47,46}
		},
		meeting_idleup = {
			frames = {{0,3}},
			clip = {0,0,47,46}
		},
		meeting_idleup_lookleft = {
			frames = {{0,5}},
			clip = {0,0,47,46}
		},
		meeting_idledown_attitude = {
			frames = {{1,5}},
			clip = {0,0,47,46}
		}
    }
}