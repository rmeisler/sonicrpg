return {
    image = "juggerbothead.png",
    starting = "idleright",
    w = 35,
    h = 40,

    animations = {
		idleright = {
			frames = {{0,0}}
		},
		idle = {
			frames = {{0,0}}
		},
		hurt = {
			frames = {{0,0}}
		},
		walkright = {
			frames = {{2,0},{0,0},{1,0},{0,0}},
			speed = 0.24
		},
		roar = {
			frames = {{0,0},{3,0},{4,0}},
			speed = 0.08
		},
		undoroar = {
			frames = {{4,0},{3,0},{0,0}},
			speed = 0.1
		}
    }
}