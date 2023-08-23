return {
    image = "rotor.png",
    starting = "idleright",
    w = 65,
    h = 55,

    animations = {
		pose = {
			frames = {{0,4}}
		},
		shock = {
			frames = {{7,4}}
		},
		frozen = {
			frames = {{9,4}}
		},

		sitright = {
			frames = {{1,5}}
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
		dead = {
			frames = {{9,3}}
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

		
		sleeping = {
			frames = {{9,2}}
		},
		waking = {
			frames = {{10,2}, {9,2},{10,2}, {9,2},{10,2}, {9,2},{10,2}, {9,2}},
			speed = 0.1
		},
		awake = {
			frames = {{10,2}}
		},
		laylookleft = {
			frames = {{11,2}}
		},
		
		aimright = {
			frames = {{9,0}}
		},
		aimleft = {
			frames = {{9,1}}
		},
		aimdown = {
			frames = {{9,2}}
		},
		aimup = {
			frames = {{9,3}}
		},
		
		throwright = {
			frames = {{9,0}, {10,0}, {11,0}, {12,0}},
			speed = 0.1
		},
		throwleft = {
			frames = {{9,1}, {10,1}, {11,1}, {12,1}},
			speed = 0.1
		},
		throwdown = {
			frames = {{9,2}, {10,2}, {11,2}, {12,2}},
			speed = 0.1
		},
		throwup = {
			frames = {{9,3}, {10,3}, {11,3}, {12,3}},
			speed = 0.1
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
		},
		
		explaining_right1 = {
			frames = {{1,4}}
		},
		explaining_right2 = {
			frames = {{4,4}}
		},
		explaining_left1 = {
			frames = {{2,4}}
		},
		explaining_left2 = {
			frames = {{5,4}}
		},
		thinking = {
			frames = {{3,4}}
		},
		sad = {
			frames = {{0,5}}
		},
		hug = {
			frames = {{3,5}}
		},
		climb_1 = {
			frames = {{1,3}}
		},
		climb_2 = {
			frames = {{5,3}}
		},

		meeting_idledown = {
			frames = {{0,2}},
			clip = {0,0,47,42}
		},
		meeting_shock = {
			frames = {{7,4}},
			clip = {0,0,47,42}
		},
    }
}