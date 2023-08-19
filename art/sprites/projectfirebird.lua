return {
    image = "projectfirebird.png",
    starting = "idle",
    w = 306,
    h = 202,

    animations = {
        iceidle = {
            frames = {{0,0},{0,1}},
            speed = 0.6
        },
		fireidle = {
            frames = {{1,0},{1,1}},
            speed = 0.6
        },
		idle = {
            frames = {{2,0},{2,1}},
			speed = 0.6
        },
		iceattack = {
            frames = {{0,1},{0,3}},
			speed = 0.4
        },
		fireattack = {
            frames = {{1,1},{1,3}},
			speed = 0.4
        },
		fly = {
            frames = {{2,2},{2,3},{2,4}},
			speed = 0.4
        },
		icehurt = {
            frames = {{0,2},{2,2},{0,2},{2,2}},
			speed = 0.05
        },
		firehurt = {
            frames = {{1,2},{2,2},{1,2},{2,2}},
			speed = 0.05
        },
		hurt = {
            frames = {{2,2}}
        },
		iceconvert = {
            frames = {{0,2}}
        },
		fireconvert = {
            frames = {{1,2}}
        },
		convert = {
            frames = {{2,2}}
        }
    }
}