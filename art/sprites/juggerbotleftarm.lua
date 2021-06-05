return {
    image = "juggerbotleftarm.png",
    starting = "idleright",
    w = 60,
    h = 60,

    animations = {
		idleright = {
			frames = {{0,0}}
		},
		walkright = {
			frames = {{0,0},{1,0},{2,0},{1,0}},
			speed = 0.2
		},
		cannonright = {
			frames = {{3,0},{4,0},{5,0},{6,0},{7,0}},
			speed = 0.2
		},
		missilecannonright = {
			frames = {{8,0},{9,0},{10,0}},
			speed = 0.2
		},
		idlecannonright = {
			frames = {{7,0}}
		},
		idlemissilecannonright = {
			frames = {{10,0}}
		}
    }
}