return {
    image = "messbot.png",
    starting = "idle",
    w = 47,
    h = 55,

    animations = {
        idle = {
            frames = {{0,0},{1,0}},
			speed = 0.3
        },
		hurt = {
            frames = {{2,0}}
        },
		crouch = {
            frames = {{3,0}}
        },
		attack = {
            frames = {{4,0}}
        },

		poison_idle = {
            frames = {{0,1},{1,1}},
			speed = 0.3
        },
		poison_hurt = {
            frames = {{2,1}}
        },
		poison_crouch = {
            frames = {{3,1}}
        },
		poison_attack = {
            frames = {{4,1}}
        },
    },
}