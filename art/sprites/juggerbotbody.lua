return {
    image = "juggerbotbody.png",
    starting = "idleright",
    w = 66,
    h = 93,

    animations = {
		idleright = {
			frames = {{0,0}}
		},
		walkright = {
			frames = {{0,0},{1,0},{2,0},{3,0},{4,0},{5,0},{6,0},{7,0}},
			speed = 0.13
		},
		cannonright = {
			frames = {{8,0},{9,0},{10,0},{11,0},{12,0}},
			speed = 0.13
		},
		idlecannonright = {
			frames = {{12,0}}
		},
		undocannonright = {
			frames = {{12,0},{11,0},{10,0},{9,0},{8,0}},
			speed = 0.13
		}
    }
}