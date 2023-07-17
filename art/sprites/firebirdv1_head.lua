return {
    image = "firebirdv1_head.png",
    starting = "ice_idle",
    w = 116,
    h = 86,

    animations = {
		idle = {
			frames = {{1,0}}
		},
		hurt = {
			frames = {{0,0}}
		},

		ice_hurt = {
            frames = {{0,0}}
        },
		ice_idle = {
            frames = {{1,0}}
        },
		ice_charge1 = {
            frames = {{1,0},{2,0}},
			speed = 0.1
        },
		ice_charge2 = {
			frames = {{1,0},{3,0}},
			speed = 0.1
        },
		ice_charge3 = {
			frames = {{1,0},{4,0}},
			speed = 0.1
        },
		ice_attack = {
			frames = {{1,0},{5,0}},
			speed = 0.1
        },

		fire_hurt = {
            frames = {{6,0}}
        },
		fire_idle = {
            frames = {{7,0}}
        },
		fire_charge1 = {
			frames = {{7,0},{8,0}},
			speed = 0.1
        },
		fire_charge2 = {
			frames = {{7,0},{9,0}},
			speed = 0.1
        },
		fire_charge3 = {
			frames = {{7,0},{10,0}},
			speed = 0.1
        },
		fire_attack = {
			frames = {{7,0},{11,0}},
			speed = 0.1
        },
    }
}