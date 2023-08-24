return {
    image = "bart.png",
    starting = "idledown",
    w = 52,
    h = 58,

    animations = {
		dying = {
			frames = {{8,0}}
		},
		pose = {
			frames = {{6,0},{7,0}},
			speed = 0.4
		},
		idledown = {
			frames = {{0,0}}
		},
		idleup = {
			frames = {{3,0}}
		},
		walkdown = {
			frames = {{1,0},{0,0},{2,0},{0,0}},
			speed = 0.2
		},
		walkup = {
			frames = {{4,0},{3,0},{5,0},{3,0}},
			speed = 0.2
		}
    }
}