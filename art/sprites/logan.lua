return {
    image = "logan.png",
    starting = "idle",
    w = 47,
    h = 55,

    animations = {
	    idle = {
			frames = {{0,1}}
		},
		backward = {
			frames = {{0,0}}
		},
		hurt = {
			frames = {{13,2}}
		},
		prethrow = {
			frames = {{1,7}}
		},
		throw = {
			frames = {{1,7},{2,7},{3,7}},
			speed = 0.1
		},
		frozen = {
			frames = {{10,6}}
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
			frames = {{1,2}, {2,2}, {3,2}, {4,2}, {5,2}, {6,2}, {7,2}, {8,2}},
			speed = 0.09
		},
		walkup = {
			frames = {{1,3}, {2,3}, {3,3}, {4,3},{5,3}, {6,3}, {7,3}, {8,3}},
			speed = 0.09
		},
		
		crouchright = {
            frames = {{0,0}}
        },
		crouchleft = {
			frames = {{0,1}}
		},
		crouchdown = {
			frames = {{0,2}}
		},
		crouchup = {
			frames = {{0,3}}
		},

		jumpright = {
            frames = {{3,0}}
        },
		jumpleft = {
			frames = {{3,1}}
		},
		jumpdown = {
			frames = {{3,2}}
		},
		jumpup = {
			frames = {{3,3}}
		},

		
		sadleft = {
			frames = {{0,6}}
		},
		sitright = {
            frames = {{9,0}}
        },
		attitude = {
			frames = {{1,5}}
		},
		pose = {
			frames = {{1,5}}
		},
		victory = {
			frames = {{1,5}}
		},
		dead = {
			frames = {{7,6}}
		},
		irritated = {
			frames = {{1,6}}
		},
		shock = {
			frames = {{11,4}}
		},
		sleeping = {
			frames = {{7,5}}
		},
		scan = {
			frames = {{6,6},{5,6}},
			speed = 0.2
		},
		scandown = {
			frames = {{3,6}}
		},
		waking = {
			frames = {{6,5},{7,5},{6,5},{7,5},{6,5},{7,5}},
			speed = 0.1
		},
		laying = {
			frames = {{6,5}}
		},
		cold = {
			frames = {{8,5}}
		},
		shiver = {
			frames = {{8,5},{9,5},{8,5},{10,5}},
			speed = 0.07
		},
		leapdown = {
			frames = {{7,2}}
		},
		snowboard = {
			frames = {{4,5}}
		},
		snowboard_ramp = {
			frames = {{5,5}}
		},
		snowboard_leap = {
			frames = {{4,6}}
		},
		snowboard_fail = {
			frames = {{4,7}}
		},
		climb_1 = {
			frames = {{1,3}}
		},
		climb_2 = {
			frames = {{5,3}}
		},

		meeting_idledown = {
			frames = {{0,2}},
			clip = {0,0,47,46}
		},
		meeting_idleup = {
			frames = {{0,3}},
			clip = {0,0,47,46}
		},
		meeting_idleright = {
			frames = {{0,0}},
			clip = {0,0,47,46}
		},
		meeting_idleleft = {
			frames = {{0,1}},
			clip = {0,0,47,46}
		},
		meeting_idleup_lookleft = {
			frames = {{0,5}},
			clip = {0,0,47,46}
		},
		meeting_idledown_attitude = {
			frames = {{1,5}},
			clip = {0,0,47,46}
		},
		angrydown = {
			frames = {{2,6}}
		},
    }
}