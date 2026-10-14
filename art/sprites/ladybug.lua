return {
    image = "ladybug.png",
    starting = "idle",
    w = 70,
    h = 70,

    animations = {
        idle = {
            frames = {{0,0}}
        },
		move = {
            frames = {{1,0},{2,0},{3,0}},
			speed = 0.06
        },
		hurt = {
            frames = {{0,0}}
        },

		level2_idle = {
            frames = {{4,0}}
        },
		level2_move = {
            frames = {{5,0}}
        },
		level2_hurt = {
            frames = {{6,0}}
        },
		
		level3_idle = {
            frames = {{7,0}}
        },
		level3_move = {
            frames = {{8,0}}
        },
		level3_hurt = {
            frames = {{9,0}}
        },
    }
}