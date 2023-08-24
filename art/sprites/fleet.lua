return {
    image = "fleet.png",
    starting = "idle",
    w = 47,
    h = 55,

    animations = {
        flyleft = {
			frames = {{9,4}}
		},
		flyright = {
			frames = {{9,5}}
		},
		idle = {
			frames = {{5,7}}
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
		idleup_lookleft = {
			frames = {{0,5}}
		},
		lookright = {
			frames = {{1,5}}
		},
		frustrated = {
			frames = {{1,7}}
		},
		smirkright = {
			frames = {{10,4}}
		},
		smirk = {
			frames = {{1,6}}
		},
		laugh = {
			frames = {{2,6},{3,6}},
			speed = 0.2
		},
		hatlaugh = {
			frames = {{4,6},{5,6}},
			speed = 0.2
		},
		hatsmirk = {
			frames = {{4,7}}
		},
		hatfrustrated = {
			frames = {{2,7}}
		},
		hurt = {
			frames = {{6,6}}
		},
		prethrow = {
			frames = {{6,7}}
		},
		throw = {
			frames = {{7,7},{8,7}},
			speed = 0.1
		},
		shock = {
			frames = {{11,4}}
		},
		
		meeting_idledown = {
			frames = {{0,2}},
			clip = {0,0,47,44}
		},
		meeting_idleup = {
			frames = {{0,6}},
			clip = {0,0,47,44}
		},
		meeting_idleup_lookleft = {
			frames = {{0,5}},
			clip = {0,0,47,44}
		},
		meeting_lookright = {
			frames = {{1,5}},
			clip = {0,0,47,44}
		},
		meeting_smirkright = {
			frames = {{10,4}},
			clip = {0,0,47,44}
		},
		meeting_smirk = {
			frames = {{1,6}},
			clip = {0,0,47,44}
		},
		meeting_laugh = {
			frames = {{2,6},{3,6}},
			speed = 0.2,
			clip = {0,0,47,44}
		},
		meeting_idleright = {
			frames = {{0,0}},
			clip = {0,0,47,44}
		},
		meeting_idleleft = {
			frames = {{0,1}},
			clip = {0,0,47,44}
		},
		meeting_shock = {
			frames = {{11,4}},
			clip = {0,0,47,44}
		},
    }
}