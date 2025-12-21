return {
    image = "robotnikbattle.png",
    starting = "ground",
    w = 125,
    h = 125,

    animations = {
        idle = {
            frames = {{0,0},{1,0}},
			speed = 0.1
        },
		flyup = {
            frames = {{2,1},{3,1}},
			speed = 0.1
        },
		laser = {
            frames = {{0,2},{1,2}},
			speed = 0.1
        },
		shield = {
            frames = {{2,2},{3,2}},
			speed = 0.1
        },
		shieldbreak = {
            frames = {{0,7},{1,7}},
			speed = 0.1
        },
		hurt = {
            frames = {{0,3},{1,3}},
			speed = 0.1
        },
		shock = {
            frames = {{0,3},{1,3}},
			speed = 0.1
        },
		veryhurt = {
            frames = {{2,3}}
        },
		knockdown = {
            frames = {{3,3}}
        },
		ground = {
            frames = {{0,4}}
        },
		lunge = {
            frames = {{2,0},{3,0}},
			speed = 0.1
        },
		grab = {
            frames = {{0,1},{1,1}},
			speed = 0.1
        },
		angry = {
            frames = {{0,5},{1,5}},
			speed = 0.1
        },
		scary = {
            frames = {{2,5},{3,5}},
			speed = 0.1
        },
		comehere1 = {
            frames = {{0,6},{1,6}},
			speed = 0.1
        },
		comehere2 = {
            frames = {{2,6},{3,6}},
			speed = 0.1
        },
		throw = {
            frames = {{1,4},{2,4}},
			speed = 0.1
        },
		throw_smear = {
            frames = {{3,4}}
        }
    }
}